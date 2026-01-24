"""MkDocs hooks for dynamic gallery generation."""

import os
import re
from pathlib import Path
from collections import defaultdict


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
    
    # Read all panel.md files from panel subdirectories
    for panel_subdir in Path(panels_dir).iterdir():
        if not panel_subdir.is_dir():
            continue
        
        panel_file = panel_subdir / 'panel.md'
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
            'thumbnail': thumbnail
        })
    
    # Group by category
    categories = defaultdict(list)
    for panel in panels:
        categories[panel['category']].append(panel)
    
    # Define category order
    category_order = ['Analog Control', 'Visual Feedback', 'Connectivity', 'Digital I/O', 'Audio', 'Power', 'Other']
    
    return categories, category_order, panels


def on_page_markdown(markdown, page, config, files):
    """Process gallery.md to inject dynamic content."""
    if page.file.src_path != 'gallery.md':
        return markdown
    
    panels_dir = os.path.join(config['docs_dir'], 'panels')
    categories, category_order, panels = generate_gallery_categories(panels_dir)
    
    # Generate category tabs as raw HTML to bypass markdown parsing
    tabs_html = '<div class="tabbed-set tabbed-alternate">\n'
    
    # Add radio buttons and labels
    tab_names = ['All'] + sorted(categories.keys())
    for i, tab_name in enumerate(tab_names, 1):
        checked = 'checked="checked" ' if i == 1 else ''
        tabs_html += f'<input {checked}id="tab_{i}" name="tabs" type="radio" />'
    
    tabs_html += '<div class="tabbed-labels">\n'
    for i, tab_name in enumerate(tab_names, 1):
        tabs_html += f'<label for="tab_{i}">{tab_name}</label>\n'
    tabs_html += '</div>\n'
    
    tabs_html += '<div class="tabbed-content">\n'
    
    # Add "All" tab content
    tabs_html += '<div class="tabbed-block">\n'
    for p in sorted(panels, key=lambda x: x['title']):
        tabs_html += '<div class="panel-card">\n'
        tabs_html += f'<a href="panels/{p["filename"]}/" data-title="{p["title"]}"><img src="{p["thumbnail"]}" alt="{p["title"]}" /></a>\n'
        tabs_html += f'<p>{p["description"]}</p>\n'
        tabs_html += '</div>\n'
    tabs_html += '</div>\n'
    
    # Add category tab content
    for category in sorted(categories.keys()):
        tabs_html += '<div class="tabbed-block">\n'
        for p in categories[category]:
            tabs_html += '<div class="panel-card">\n'
            tabs_html += f'<a href="panels/{p["filename"]}/" data-title="{p["title"]}"><img src="{p["thumbnail"]}" alt="{p["title"]}" /></a>\n'
            tabs_html += f'<p>{p["description"]}</p>\n'
            tabs_html += '</div>\n'
        tabs_html += '</div>\n'
    
    tabs_html += '</div>\n</div>\n'
    
    # Replace the marker with HTML
    markdown = re.sub(
        r'<!-- CATEGORY_TABS_START -->.*?<!-- CATEGORY_TABS_END -->',
        f'<!-- CATEGORY_TABS_START -->\n{tabs_html}\n<!-- CATEGORY_TABS_END -->',
        markdown,
        flags=re.DOTALL
    )
    
    # Update statistics
    stats = f"""- **Total Panels**: {len(panels)}
- **Contributors**: {len(set(p['contributor'] for p in panels))}
- **Categories**: {', '.join(sorted(categories.keys()))}"""
    
    markdown = re.sub(
        r'<!-- STATS_START -->.*?<!-- STATS_END -->',
        f'<!-- STATS_START -->\n{stats}\n<!-- STATS_END -->',
        markdown,
        flags=re.DOTALL
    )
    
    return markdown
