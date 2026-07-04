"""
Panel submission automation script.
Parses a GitHub issue created from the panel submission template and generates
the necessary files for adding a panel to the gallery.
"""

import os
import re
import sys
import json
import requests
from pathlib import Path
from datetime import datetime
from urllib.parse import urlparse


def parse_issue_body(body):
    """Parse GitHub issue form body into a dictionary."""
    data = {}
    current_field = None
    current_value = []
    
    lines = body.split('\n')
    
    for line in lines:
        # Check if this is a field header (### FieldLabel)
        if line.startswith('### '):
            # Save previous field
            if current_field:
                data[current_field] = '\n'.join(current_value).strip()
            
            # Start new field
            current_field = line[4:].strip()
            current_value = []
        elif current_field:
            # Skip "No response" and empty lines at start
            if line.strip() and line.strip() != '_No response_':
                current_value.append(line)
    
    # Save last field
    if current_field:
        data[current_field] = '\n'.join(current_value).strip()
    
    return data


def get_field(data, *names, default=''):
    """Return the first non-empty field value from a list of possible names."""
    for name in names:
        value = data.get(name)
        if value is not None and str(value).strip():
            return str(value).strip()
    return default


def determine_category(data):
    """Resolve panel category, including custom category override."""
    category = get_field(data, 'Panel Category', default='Other')
    custom_category = get_field(data, 'Custom Category (if "Other" selected)', 'Custom Category')
    if custom_category:
        return custom_category
    return category or 'Other'


def extract_checkboxes(text):
    """Extract checked checkbox values."""
    checked = []
    for line in text.split('\n'):
        if line.strip().startswith('- [X]') or line.strip().startswith('- [x]'):
            checked.append(line.strip()[6:].strip())
    return checked


def download_image(url, output_path):
    """Download an image from a URL."""
    response = requests.get(url, stream=True)
    response.raise_for_status()
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'wb') as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)
    
    return output_path


def extract_images_from_text(text):
    """Extract image URLs from markdown text."""
    # Match GitHub uploaded images: ![image](https://...)
    pattern = r'!\[.*?\]\((https://[^\)]+)\)'
    matches = re.findall(pattern, text)
    return matches


def sanitize_filename(name):
    """Convert panel name to safe filename."""
    # Remove special characters, convert to lowercase, replace spaces with hyphens
    name = re.sub(r'[^\w\s-]', '', name.lower())
    name = re.sub(r'[\s_]+', '-', name)
    return name.strip('-')


def _parse_int(value):
    """Parse an integer from a value that may include units/text."""
    if value is None:
        return None

    text = str(value).strip()
    if not text:
        return None

    match = re.search(r'\d+', text)
    if not match:
        return None

    return int(match.group(0))


def resolve_dimensions(data):
    """Resolve horizontal pitch (HP) and vertical units (U), with legacy size fallback."""
    horizontal_pitch = _parse_int(get_field(
        data,
        'Horizontal Pitch (HP)',
        'Horizontal Pitch',
        'Panel Horizontal Pitch',
        'horizontalPitch',
        default=''
    ))
    vertical_units = _parse_int(get_field(
        data,
        'Vertical Units (U)',
        'Vertical Units',
        'Panel Vertical Units',
        'verticalUnits',
        default=''
    ))

    if horizontal_pitch is not None and vertical_units is not None:
        return horizontal_pitch, vertical_units

    # Backward compatibility for old single size field, e.g. "8 HP x 3U"
    panel_size = get_field(data, 'Panel Size', default='')
    if panel_size:
        match = re.search(r'(\d+)\s*HP\s*[x×]\s*(\d+)\s*U', panel_size, re.IGNORECASE)
        if match:
            return int(match.group(1)), int(match.group(2))

    return horizontal_pitch, vertical_units


def format_panel_size(horizontal_pitch, vertical_units):
    """Format dimensions as a user-friendly size string."""
    if horizontal_pitch is None or vertical_units is None:
        return 'Unknown'
    return f'{horizontal_pitch} HP × {vertical_units}U'


def resolve_scad_file_url(data):
    """Resolve optional SCAD file pointer for manifest entries."""
    explicit_scad_url = get_field(data, 'SCAD File URL (optional)', 'SCAD File URL', default='')
    if explicit_scad_url:
        return explicit_scad_url

    design_url = get_field(data, 'GitHub Repository or Design Files URL', default='')
    if design_url and '.scad' in design_url.lower():
        return design_url

    return ''


def generate_panel_markdown(data, panel_slug):
    """Generate the panel detail page markdown."""

    panel_name = get_field(data, 'Panel Name', default='Untitled Panel')
    description = get_field(data, 'Tell us about your panel', default='No description provided.')
    short_description = get_field(data, 'One-line description')
    horizontal_pitch, vertical_units = resolve_dimensions(data)
    panel_size = format_panel_size(horizontal_pitch, vertical_units)
    contributor = get_field(data, 'Submitted By', 'Your Name', default='Community')
    github_user = get_field(data, 'Your GitHub Username', default=contributor if contributor != 'Community' else 'unknown')
    github_url = get_field(data, 'GitHub Repository or Design Files URL', default='')
    license_name = get_field(data, 'License', default='Unknown')
    category = determine_category(data)

    features = get_field(data, 'Key Features')
    if features and not features.startswith('-'):
        # Convert to bullet list if not already
        features = '\n'.join(f"- {line.strip()}" for line in features.split('\n') if line.strip())
    if not features:
        features = '- Details coming soon.'
    
    # Build purchase section
    purchase_section = ""
    buy_url = get_field(data, 'Buy Now URL (optional)', 'Purchase URL (optional)')
    if buy_url:
        purchase_section = f"""
## Where to Buy

- **Buy Now**: [Purchase here]({buy_url})
"""

    # Build BOM section
    bom_section = ""
    if 'Bill of Materials (optional)' in data and data['Bill of Materials (optional)'].strip():
        bom = data['Bill of Materials (optional)'].strip()
        if not bom.startswith('|'):
            # Wrap in markdown table if not already
            bom_section = f"""
## Bill of Materials

{bom}
"""
        else:
            bom_section = f"""
## Bill of Materials

{bom}
"""
    
    # Power requirements
    power = get_field(data, 'Power Requirements (optional)', default='Passive (no power required)')
    if not power:
        power = 'Passive (no power required)'

    design_files_section = "- Design files link not provided."
    if github_url:
        design_files_section = f"- [GitHub Repository/Files]({github_url})"
    
    markdown = f"""---
title: {panel_name}
category: {category}
horizontalPitch: {horizontal_pitch if horizontal_pitch is not None else 'Unknown'}
verticalUnits: {vertical_units if vertical_units is not None else 'Unknown'}
size: {panel_size}
contributor: {contributor}
thumbnail: images/thumb.png
description: {short_description}
---

<!-- Copyright (c) {datetime.now().year} Ranch Hand Robotics, LLC. All rights reserved. Licensed under MIT License. -->

# {panel_name}

![{panel_name}](images/thumb.png)

## Overview

{description}
{purchase_section}
## Specifications

- **Horizontal Pitch**: {horizontal_pitch if horizontal_pitch is not None else 'Unknown'} HP
- **Vertical Units**: {vertical_units if vertical_units is not None else 'Unknown'}U
- **Depth**: {get_field(data, 'Panel Depth', default='Unknown')}
- **Material**: {get_field(data, 'Material', default='Unknown')}
- **Power Requirements**: {power}
- **Mounting**: T-slot compatible (M5/M6 twist nuts)

## Features

{features}

## Design Files

{design_files_section}
{bom_section}
## License

This design is released under the **{license_name}** license.

## Author

**{contributor}**  
GitHub: [@{github_user}](https://github.com/{github_user})  
Date: {datetime.now().strftime('%B %Y')}

---

[← Back to Gallery](../../gallery.html)
"""
    
    return markdown


def update_gallery(panel_data, panel_slug, issue_number, thumbnail_path):
    """Upsert a panel record in docs/gallery.json for client-side rendering."""
    gallery_json_path = Path('docs/gallery.json')

    payload = {'panels': []}
    if gallery_json_path.exists():
        with open(gallery_json_path, 'r', encoding='utf-8') as f:
            existing = json.load(f)
            if isinstance(existing, dict):
                payload = existing

    payload.setdefault('panels', [])

    panel_name = get_field(panel_data, 'Panel Name', default='Untitled Panel')
    horizontal_pitch, vertical_units = resolve_dimensions(panel_data)
    description = get_field(panel_data, 'One-line description', default='')
    category = determine_category(panel_data)
    buy_url = get_field(panel_data, 'Buy Now URL (optional)', 'Purchase URL (optional)')
    contributor = get_field(panel_data, 'Submitted By', 'Your Name', default='Community')
    scad_file_url = resolve_scad_file_url(panel_data)

    entry = {
        'slug': panel_slug,
        'title': panel_name,
        'category': category,
        'horizontalPitch': horizontal_pitch,
        'verticalUnits': vertical_units,
        'contributor': contributor,
        'description': description,
        'thumbnail': thumbnail_path,
        'panel_url': f'panels/{panel_slug}/index.html',
        'buy_url': buy_url,
        'issue_number': int(issue_number),
        'updated_at': datetime.utcnow().replace(microsecond=0).isoformat() + 'Z'
    }

    if scad_file_url:
        entry['scadFile'] = scad_file_url

    panels = payload['panels']
    existing_index = next((i for i, item in enumerate(panels) if item.get('slug') == panel_slug), None)

    if existing_index is None:
        panels.append(entry)
        print(f"Added panel to gallery.json: {panel_slug}")
    else:
        panels[existing_index] = entry
        print(f"Updated panel in gallery.json: {panel_slug}")

    panels.sort(key=lambda x: x.get('title', '').lower())
    payload['version'] = 1
    payload['updated_at'] = datetime.utcnow().replace(microsecond=0).isoformat() + 'Z'

    with open(gallery_json_path, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2)
        f.write('\n')

    print(f"gallery.json updated: {gallery_json_path}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python process_panel_issue.py <issue_number>")
        sys.exit(1)
    
    issue_number = sys.argv[1]
    github_token = os.environ.get('GITHUB_TOKEN')
    if not github_token:
        print("Error: GITHUB_TOKEN environment variable is required")
        sys.exit(1)
    
    # Get repository info from environment or default
    repo_owner = os.environ.get('GITHUB_REPOSITORY_OWNER', 'Ranch-Hand-Robotics')
    repo_name = os.environ.get('GITHUB_REPOSITORY', 'Ranch-Hand-Robotics/makerpanel').split('/')[-1]
    
    # Fetch issue from GitHub
    api_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/issues/{issue_number}"
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    print(f"Fetching issue #{issue_number} from {repo_owner}/{repo_name}...")
    response = requests.get(api_url, headers=headers)
    response.raise_for_status()
    
    issue = response.json()
    
    # Check if it has the right label
    labels = [label['name'] for label in issue.get('labels', [])]
    if 'new-panel' not in labels:
        print(f"Error: Issue #{issue_number} does not have 'new-panel' label")
        sys.exit(1)
    
    print(f"Processing issue: {issue['title']}")
    
    # Parse issue body
    panel_data = parse_issue_body(issue.get('body') or '')
    panel_data['Submitted By'] = issue.get('user', {}).get('login', 'Community')
    panel_data['Issue Number'] = str(issue_number)
    
    print("\nExtracted panel data:")
    for key, value in panel_data.items():
        print(f"  {key}: {value[:100]}..." if len(str(value)) > 100 else f"  {key}: {value}")
    
    # Generate panel slug
    panel_name = get_field(panel_data, 'Panel Name', default='').strip()
    if not panel_name:
        panel_name = issue.get('title', 'untitled-panel').replace('[Panel]', '').strip() or 'untitled-panel'
    panel_slug = sanitize_filename(panel_name)
    
    print(f"\nPanel slug: {panel_slug}")
    
    # Create panel directory structure
    panel_dir = Path(f'docs/panels/{panel_slug}')
    images_dir = panel_dir / 'images'
    images_dir.mkdir(parents=True, exist_ok=True)
    
    # Download thumbnail image
    thumbnail_text = panel_data.get('Thumbnail Image', '')
    thumbnail_urls = extract_images_from_text(thumbnail_text)
    
    if thumbnail_urls:
        print(f"\nDownloading thumbnail...")
        thumbnail_url = thumbnail_urls[0]
        # Get file extension from URL
        ext = os.path.splitext(urlparse(thumbnail_url).path)[1] or '.png'
        thumbnail_path = images_dir / f'thumb{ext}'
        download_image(thumbnail_url, thumbnail_path)
        print(f"  Saved to: {thumbnail_path}")
        
        thumbnail_web_path = f'panels/{panel_slug}/images/thumb{ext}'
    else:
        print("\nWarning: No thumbnail image found in issue")
        thumbnail_web_path = f'panels/{panel_slug}/images/thumb.png'
    
    # Download additional images
    additional_images_text = panel_data.get('Additional Photos (optional)', '')
    additional_urls = extract_images_from_text(additional_images_text)
    
    if additional_urls:
        print(f"\nDownloading {len(additional_urls)} additional images...")
        for i, url in enumerate(additional_urls, 1):
            ext = os.path.splitext(urlparse(url).path)[1] or '.png'
            img_path = images_dir / f'image-{i}{ext}'
            download_image(url, img_path)
            print(f"  Saved: {img_path}")
    
    # Generate panel markdown
    print(f"\nGenerating panel markdown...")
    panel_markdown = generate_panel_markdown(panel_data, panel_slug)
    
    # Handle thumbnail extension
    if thumbnail_urls:
        ext = os.path.splitext(urlparse(thumbnail_urls[0]).path)[1] or '.png'
        panel_markdown = panel_markdown.replace('thumb.png', f'thumb{ext}')
    
    panel_md_path = panel_dir / 'index.md'
    with open(panel_md_path, 'w') as f:
        f.write(panel_markdown)
    
    print(f"  Created: {panel_md_path}")
    
    # Update gallery
    print(f"\nUpdating gallery...")
    update_gallery(panel_data, panel_slug, issue_number, thumbnail_web_path)
    
    # Comment on the issue
    comment_url = f"{api_url}/comments"
    comment_body = f"""✅ **Panel processed successfully!**

Your panel has been added to the gallery:
- **Directory**: `docs/panels/{panel_slug}/`
- **Preview**: Will be available after deployment

A maintainer will review and merge the changes soon. Thank you for your contribution! 🎉
"""
    
    comment_response = requests.post(
        comment_url,
        headers=headers,
        json={'body': comment_body}
    )
    
    if comment_response.status_code == 201:
        print("  Posted success comment to issue")
    
    print("\n✅ Panel processing complete!")
    print(f"\nNext steps:")
    print(f"  1. Review generated files in docs/panels/{panel_slug}/")
    print(f"  2. Verify docs/gallery.json entry for this panel")
    print(f"  3. Commit and push changes")
    print(f"  4. Deploy will run automatically")


if __name__ == '__main__':
    main()
