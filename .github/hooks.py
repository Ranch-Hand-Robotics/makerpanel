"""MkDocs hooks for dynamic gallery generation."""

import json
import os
import re
import shutil
from pathlib import Path
from collections import defaultdict
from datetime import datetime


EXAMPLES_DIR = Path('examples')
MAKERPANEL_SCAD_DIR = Path('makerpanel')
GALLERY_JSON_PATH = Path('docs/gallery.json')
GENERATED_SCAD_DIR = Path('docs/generated/scad')
EXAMPLE_PANEL_URL_PREFIX = 'https://github.com/Ranch-Hand-Robotics/makerpanel/tree/main/examples/'
DEFAULT_EXAMPLE_THUMBNAIL = 'images/makerpanel.png'

# Metadata for built-in examples that live under /examples.
EXAMPLE_OVERRIDES = {
    'joystick': {
        'title': 'Joystick Panel',
        'category': 'Digital I/O',
        'horizontalPitch': 17,
        'verticalUnits': 2,
        'scadFile': 'generated/scad/examples/joystick/design/joystick.scad',
        'description': 'Panel with a circular cutout for a SaiDian 4-axis mini joystick module. Laser-cuttable or 3D printable, with four M3 mounting holes.'
    },
    'lilygo_screen_4_7_s3': {
        'title': 'LilyGo Screen 4.7" S3 Panel',
        'category': 'Visual Feedback',
        'horizontalPitch': 26,
        'verticalUnits': 2,
        'scadFile': 'generated/scad/examples/lilygo_screen_4_7_s3/lilygo_screen.scad',
        'description': 'Panel for the LilyGo 4.7" S3 screen with a ribbon cable cutout for rear PCB/battery routing.'
    },
    'lilygo_t-encoder-pro': {
        'title': 'LilyGo T-Encoder Pro Panel',
        'category': 'Analog Control',
        'horizontalPitch': 9,
        'verticalUnits': 1,
        'scadFile': 'generated/scad/examples/lilygo_t-encoder-pro/lilygo_t-encoder-pro.scad',
        'description': 'Compact panel with a circular cutout for the LilyGo T-Encoder Pro rotary encoder.'
    },
    'iris_keyboard': {
        'title': 'Iris Keyboard Panel',
        'category': 'Digital I/O',
        'horizontalPitch': 35,
        'verticalUnits': 4,
        'scadFile': 'generated/scad/examples/iris_keyboard/IrisMakerPanel.scad',
        'description': 'Panel for mounting an Iris split keyboard, with an SVG-based keyboard cutout and MakerPanel-compatible mounting.'
    },
    'measure': {
        'title': 'Measurement Gauge',
        'category': 'Tools',
        'horizontalPitch': 35,
        'verticalUnits': 4,
        'scadFile': 'generated/scad/examples/measure/measure.scad',
        'description': '3D-printable gauge for verifying MakerPanel dimensions, HP spacing, and rack measurements.'
    },
    'mouse_panel': {
        'title': 'Mouse Pad Panel',
        'category': 'Tools',
        'horizontalPitch': 35,
        'verticalUnits': 5,
        'scadFile': 'generated/scad/examples/mouse_panel/MousePadPanel.scad',
        'description': 'Flat mouse pad panel design for MakerPanel-compatible decks with laser-cut and 3D printable outputs.'
    }
}


def _iso_now():
    return datetime.utcnow().replace(microsecond=0).isoformat() + 'Z'


def _title_from_slug(slug):
    return slug.replace('_', ' ').replace('-', ' ').title()


def _find_scad_url(slug):
    example_dir = EXAMPLES_DIR / slug
    if not example_dir.exists():
        return ''

    scad_files = sorted(example_dir.rglob('*.scad'))
    if not scad_files:
        return ''

    relative_scad = scad_files[0].relative_to(example_dir).as_posix()
    return f'generated/scad/examples/{slug}/{relative_scad}'


def _find_scad_assets(slug):
    """Find auxiliary files (e.g., SVG imports) for SCAD rendering."""
    example_dir = EXAMPLES_DIR / slug
    if not example_dir.exists():
        return []

    assets = []
    for path in sorted(example_dir.rglob('*')):
        if not path.is_file():
            continue
        if path.suffix.lower() not in {'.svg'}:
            continue
        assets.append(path.relative_to(example_dir).as_posix())

    return assets


def _copy_tree_by_suffixes(src_root, dst_root, suffixes):
    if not src_root.exists():
        return 0

    count = 0
    for path in src_root.rglob('*'):
        if not path.is_file() or path.suffix.lower() not in suffixes:
            continue

        relative = path.relative_to(src_root)
        destination = dst_root / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, destination)
        count += 1

    return count


def sync_scad_assets_for_gallery():
    """Publish SCAD assets into docs/ so they are available to client-side WASM rendering."""
    if GENERATED_SCAD_DIR.exists():
        shutil.rmtree(GENERATED_SCAD_DIR)

    examples_dst = GENERATED_SCAD_DIR / 'examples'
    makerpanel_dst = GENERATED_SCAD_DIR / 'makerpanel'

    suffixes = {'.scad', '.svg'}
    copied_examples = _copy_tree_by_suffixes(EXAMPLES_DIR, examples_dst, suffixes)
    copied_support = _copy_tree_by_suffixes(MAKERPANEL_SCAD_DIR, makerpanel_dst, suffixes)

    print(
        f'MkDocs hook: synced SCAD assets to {GENERATED_SCAD_DIR} '
        f'({copied_examples} example files, {copied_support} support files).'
    )


def _build_example_entry(slug):
    override = EXAMPLE_OVERRIDES.get(slug, {})
    scad_file = override.get('scadFile') or _find_scad_url(slug)

    entry = {
        'slug': slug,
        'title': override.get('title', _title_from_slug(slug)),
        'category': override.get('category', 'Other'),
        'horizontalPitch': override.get('horizontalPitch'),
        'verticalUnits': override.get('verticalUnits'),
        'contributor': 'Ranch Hand Robotics',
        'description': override.get('description', 'Makerpanel example design.'),
        'thumbnail': DEFAULT_EXAMPLE_THUMBNAIL,
        'panel_url': f'{EXAMPLE_PANEL_URL_PREFIX}{slug}',
        'buy_url': '',
        'issue_number': 0,
        'updated_at': _iso_now()
    }

    if scad_file:
        entry['scadFile'] = scad_file

    scad_assets = _find_scad_assets(slug)
    if scad_assets:
        entry['scadAssets'] = scad_assets

    return entry


def sync_examples_into_gallery_json():
    """Upsert local /examples entries into docs/gallery.json before build."""
    if not EXAMPLES_DIR.exists() or not EXAMPLES_DIR.is_dir():
        print('MkDocs hook: examples directory not found, skipping gallery.json example sync.')
        return

    payload = {'version': 1, 'updated_at': _iso_now(), 'panels': []}
    if GALLERY_JSON_PATH.exists():
        with open(GALLERY_JSON_PATH, 'r', encoding='utf-8') as f:
            existing = json.load(f)
            if isinstance(existing, dict):
                payload = existing

    panels = payload.get('panels', [])
    if not isinstance(panels, list):
        panels = []

    example_slugs = sorted(
        item.name
        for item in EXAMPLES_DIR.iterdir()
        if item.is_dir() and not item.name.startswith('.')
    )

    if not example_slugs:
        print('MkDocs hook: no example directories found, skipping gallery.json example sync.')
        return

    entry_by_slug = {entry.get('slug'): entry for entry in panels if isinstance(entry, dict) and entry.get('slug')}

    for slug in example_slugs:
        entry_by_slug[slug] = _build_example_entry(slug)

    # Remove stale auto-managed example entries for directories that no longer exist.
    for slug, entry in list(entry_by_slug.items()):
        if not isinstance(entry, dict):
            continue
        panel_url = str(entry.get('panel_url', ''))
        is_example_entry = panel_url.startswith(EXAMPLE_PANEL_URL_PREFIX)
        if is_example_entry and slug not in example_slugs:
            del entry_by_slug[slug]

    updated_panels = sorted(entry_by_slug.values(), key=lambda panel: str(panel.get('title', '')).lower())
    payload['panels'] = updated_panels
    payload['version'] = 1
    payload['updated_at'] = _iso_now()

    with open(GALLERY_JSON_PATH, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2)
        f.write('\n')

    print(f'MkDocs hook: synced {len(example_slugs)} examples into {GALLERY_JSON_PATH}.')


def parse_panel_metadata(filepath):
    """Extract metadata from a panel markdown file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract front matter if present
    metadata = {}
    if content.startswith('---'):
        parts = content.split('---', 2)
        if len(parts) >= 3:
            frontmatter = parts[1].strip()
            for line in frontmatter.split('\n'):
                if ':' in line:
                    key, value = line.split(':', 1)
                    metadata[key.strip()] = value.strip().strip('"\'')
    
    # Fallback: extract from content if no front matter
    if not metadata:
        # Extract title (first H1)
        title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
        if title_match:
            metadata['title'] = title_match.group(1)
        
        # Extract overview
        overview_match = re.search(r'## Overview\s+(.+?)(?=\n##|\n\n##|\Z)', content, re.DOTALL)
        if overview_match:
            desc = overview_match.group(1).strip()
            # Get first sentence or line
            metadata['description'] = desc.split('\n')[0].strip()
        
        # Extract specifications
        specs_match = re.search(r'##\s+Specifications.+?-\s+\*\*Size\*\*:\s*([^\n]+)', content, re.DOTALL)
        if specs_match:
            metadata['size'] = specs_match.group(1).strip()
    
    return metadata


def generate_gallery_categories(panels_dir):
    """Generate gallery content organized by categories."""
    panels = []
    
    # Read all index.md files from panel subdirectories
    for panel_subdir in Path(panels_dir).iterdir():
        if not panel_subdir.is_dir():
            continue
        
        panel_file = panel_subdir / 'index.md'
        if not panel_file.exists():
            continue
        
        metadata = parse_panel_metadata(panel_file)
        
        # Use directory name as panel identifier
        panel_name = panel_subdir.name
        
        # Infer category based on keywords or explicit metadata
        category = metadata.get('category', '')
        if not category:
            if 'pot' in panel_name or 'potentiometer' in panel_name.lower():
                category = 'Analog Control'
            elif 'led' in panel_name or 'indicator' in panel_name.lower():
                category = 'Visual Feedback'
            elif 'usb' in panel_name or 'hub' in panel_name.lower():
                category = 'Connectivity'
            else:
                category = 'Other'
        
        # Get thumbnail - convert relative paths to absolute gallery context
        # Panel front matter has relative path (images/thumb.svg), need full path for gallery
        thumbnail_raw = metadata.get('thumbnail', f'images/thumb.svg')
        if thumbnail_raw.startswith('images/'):
            # Convert relative panel path to gallery-relative path
            thumbnail = f'panels/{panel_name}/{thumbnail_raw}'
        else:
            # Use path as-is if already absolute or custom
            thumbnail = thumbnail_raw
        
        panels.append({
            'filename': panel_name,
            'title': metadata.get('title', panel_name.replace('-', ' ').title()),
            'category': category,
            'size': metadata.get('size', 'Unknown'),
            'contributor': metadata.get('contributor', metadata.get('author', 'Community')),
            'description': metadata.get('description', ''),
            'thumbnail': thumbnail,
            'buy_url': metadata.get('buy_url', metadata.get('purchase_url', ''))
        })
    
    # Group by category
    categories = defaultdict(list)
    for panel in panels:
        categories[panel['category']].append(panel)
    
    # Define category order
    category_order = ['Analog Control', 'Visual Feedback', 'Connectivity', 'Digital I/O', 'Audio', 'Power', 'Other']
    
    return categories, category_order, panels


def on_page_markdown(markdown, page, config, files):
    """Keep markdown unchanged; gallery content is now rendered client-side from gallery.json."""
    return markdown


def on_config(config):
    """MkDocs lifecycle hook: sync example panels before build."""
    sync_scad_assets_for_gallery()
    sync_examples_into_gallery_json()
    return config
