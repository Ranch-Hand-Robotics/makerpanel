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


def generate_panel_markdown(data, panel_slug):
    """Generate the panel detail page markdown."""
    
    features = data.get('Key Features', '').strip()
    if not features.startswith('-'):
        # Convert to bullet list if not already
        features = '\n'.join(f"- {line.strip()}" for line in features.split('\n') if line.strip())
    
    # Determine category
    category = data.get('Panel Category', 'Other')
    if 'Custom Category' in data and data['Custom Category'].strip():
        category = data['Custom Category'].strip()
    
    # Build purchase section
    purchase_section = ""
    if 'Purchase URL (optional)' in data and data['Purchase URL (optional)'].strip():
        purchase_url = data['Purchase URL (optional)'].strip()
        purchase_section = f"""
## Purchase

- **Available at**: [Purchase here]({purchase_url})
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
    power = data.get('Power Requirements (optional)', 'Passive (no power required)').strip()
    if not power:
        power = 'Passive (no power required)'
    
    markdown = f"""<!-- Copyright (c) {datetime.now().year} Ranch Hand Robotics, LLC. All rights reserved. Licensed under MIT License. -->

---
title: {data.get('Panel Name', 'Untitled Panel')}
category: {category}
size: {data.get('Panel Size', 'Unknown')}
contributor: {data.get('Your Name', 'Unknown')}
thumbnail: images/thumb.png
description: {data.get('One-line description', '')}
---

# {data.get('Panel Name', 'Untitled Panel')}

![{data.get('Panel Name', 'Panel')}](images/thumb.png)

## Overview

{data.get('Tell us about your panel', '')}
{purchase_section}
## Specifications

- **Size**: {data.get('Panel Size', 'Unknown')}
- **Depth**: {data.get('Panel Depth', 'Unknown')}
- **Material**: {data.get('Material', 'Unknown')}
- **Power Requirements**: {power}
- **Mounting**: T-slot compatible (M5/M6 twist nuts)

## Features

{features}

## Design Files

- [GitHub Repository/Files]({data.get('GitHub Repository or Design Files URL', '#')})
{bom_section}
## License

This design is released under the **{data.get('License', 'Unknown')}** license.

## Author

**{data.get('Your Name', 'Unknown')}**  
GitHub: [@{data.get('Your GitHub Username', 'unknown')}](https://github.com/{data.get('Your GitHub Username', 'unknown')})  
Date: {datetime.now().strftime('%B %Y')}

---

[← Back to Gallery](../../gallery.md)
"""
    
    return markdown


def update_gallery(panel_data, panel_slug):
    """Update the gallery.md file with the new panel."""
    gallery_path = Path('docs/gallery.md')
    
    if not gallery_path.exists():
        print(f"Warning: {gallery_path} not found")
        return
    
    with open(gallery_path, 'r') as f:
        content = f.read()
    
    # Create panel card HTML
    category = panel_data.get('Panel Category', 'Other')
    if 'Custom Category' in panel_data and panel_data['Custom Category'].strip():
        category = panel_data['Custom Category'].strip()
    
    panel_card = f"""
<div class="panel-card" data-category="{category}" style="background: linear-gradient(135deg, #2a2a2a 0%, #1f1f1f 100%); border-radius: 0.5rem; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 0 20px rgba(0, 255, 0, 0.2); border: 1px solid #00ff00;">
  <a href="panels/{panel_slug}/panel.html" style="text-decoration: none; color: inherit;">
    <div style="display: flex; gap: 1.5rem; align-items: start;">
      <img src="panels/{panel_slug}/images/thumb.png" alt="{panel_data.get('Panel Name', 'Panel')}" style="width: 150px; height: 150px; object-fit: cover; border-radius: 0.25rem; border: 2px solid #00ff00; box-shadow: 0 0 15px rgba(0, 255, 0, 0.3);">
      <div style="flex: 1;">
        <h3 style="margin-top: 0; color: #00ff00; font-size: 1.5rem; text-shadow: 0 0 5px rgba(0, 255, 0, 0.3);">{panel_data.get('Panel Name', 'Untitled Panel')}</h3>
        <p style="color: #b0b0b0; margin: 0.5rem 0;">{panel_data.get('One-line description', '')}</p>
        <div style="display: flex; gap: 1rem; margin-top: 1rem; flex-wrap: wrap;">
          <span style="background: rgba(0, 255, 0, 0.1); color: #00ff00; padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.9rem; border: 1px solid rgba(0, 255, 0, 0.3);">{panel_data.get('Panel Size', 'Unknown')}</span>
          <span style="background: rgba(0, 255, 0, 0.1); color: #00ff00; padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.9rem; border: 1px solid rgba(0, 255, 0, 0.3);">{category}</span>
          <span style="background: rgba(0, 255, 0, 0.1); color: #00ff00; padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.9rem; border: 1px solid rgba(0, 255, 0, 0.3);">by {panel_data.get('Your Name', 'Unknown')}</span>
        </div>
      </div>
    </div>
  </a>
</div>
"""
    
    # Insert before CATEGORY_TABS_END marker (or at a suitable location)
    # For now, we'll add it to a panels section. The actual gallery update
    # logic would depend on how the gallery is structured.
    
    # Update statistics
    stats_match = re.search(r'<!-- STATS_START -->.*?<!-- STATS_END -->', content, re.DOTALL)
    if stats_match:
        # Count panels by parsing existing content or incrementing
        # This is simplified - you'd want to actually count panels
        print("Gallery statistics update needed - implement panel counting logic")
    
    # For now, just log that we'd update the gallery
    print(f"Panel card generated for {panel_slug}")
    print(f"Category: {category}")
    print(f"Manual gallery update may be required")
    
    # TODO: Implement actual gallery.md update logic based on your gallery structure


def main():
    if len(sys.argv) < 3:
        print("Usage: python process_panel_issue.py <issue_number> <github_token>")
        sys.exit(1)
    
    issue_number = sys.argv[1]
    github_token = sys.argv[2]
    
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
    panel_data = parse_issue_body(issue['body'])
    
    print("\nExtracted panel data:")
    for key, value in panel_data.items():
        print(f"  {key}: {value[:100]}..." if len(str(value)) > 100 else f"  {key}: {value}")
    
    # Generate panel slug
    panel_name = panel_data.get('Panel Name', 'untitled-panel')
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
        
        # Update reference in generated markdown if not .png
        if ext != '.png':
            # We'll need to update the markdown generation
            pass
    else:
        print("\nWarning: No thumbnail image found in issue")
    
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
    
    panel_md_path = panel_dir / 'panel.md'
    with open(panel_md_path, 'w') as f:
        f.write(panel_markdown)
    
    print(f"  Created: {panel_md_path}")
    
    # Update gallery
    print(f"\nUpdating gallery...")
    update_gallery(panel_data, panel_slug)
    
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
    print(f"  2. Update docs/gallery.md with the panel card")
    print(f"  3. Commit and push changes")
    print(f"  4. Deploy will run automatically")


if __name__ == '__main__':
    main()
