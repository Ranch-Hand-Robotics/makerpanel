"""Generate static panel thumbnails from SCAD files and update docs/gallery.json.

This script is intended to run in CI (GitHub Actions) where OpenSCAD is installed.
It renders SCAD files to PNG thumbnails and writes them to:
  docs/images/panels/generated/{slug}.png

For each successfully rendered panel, docs/gallery.json is updated:
  panel["thumbnail"] = "images/panels/generated/{slug}.png"
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[2]
GALLERY_JSON = ROOT / 'docs' / 'gallery.json'
THUMB_DIR = ROOT / 'docs' / 'images' / 'panels' / 'generated'


def _is_remote_url(value: str) -> bool:
    return value.startswith('http://') or value.startswith('https://')


def _resolve_local_scad_path(scad_file: str) -> Path | None:
    """Resolve SCAD file references from gallery.json to local repo paths when possible."""
    scad_file = (scad_file or '').strip()
    if not scad_file:
        return None

    # Local repository path (relative to repo root)
    if not _is_remote_url(scad_file):
        candidate = (ROOT / scad_file).resolve()
        return candidate if candidate.exists() else None

    parsed = urlparse(scad_file)
    host = parsed.netloc.lower()
    parts = [part for part in parsed.path.split('/') if part]

    # raw.githubusercontent.com/{owner}/{repo}/{ref}/{path...}
    if host == 'raw.githubusercontent.com' and len(parts) >= 5:
        repo_relative = Path(*parts[4:])
        candidate = (ROOT / repo_relative).resolve()
        return candidate if candidate.exists() else None

    # github.com/{owner}/{repo}/tree/{ref}/{path...}
    if host == 'github.com' and len(parts) >= 6 and parts[2] == 'tree':
        repo_relative = Path(*parts[4:])
        candidate = (ROOT / repo_relative).resolve()
        return candidate if candidate.exists() else None

    return None


def _openscad_available() -> bool:
    return shutil.which('openscad') is not None


def _build_openscad_command(scad_path: Path, output_path: Path) -> list[str]:
    command = [
        'openscad',
        '--autocenter',
        '--viewall',
        '--imgsize=800,450',
        '-o',
        str(output_path),
        str(scad_path),
    ]

    # On Linux CI, use xvfb for headless rendering when available.
    if sys.platform.startswith('linux') and shutil.which('xvfb-run'):
        return ['xvfb-run', '-a', *command]

    return command


def _render_thumbnail(scad_path: Path, output_path: Path) -> bool:
    output_path.parent.mkdir(parents=True, exist_ok=True)

    command = _build_openscad_command(scad_path, output_path)
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)

    if result.returncode != 0:
        print(f'[thumbnail] Failed for {scad_path}')
        if result.stdout.strip():
            print(result.stdout.strip())
        if result.stderr.strip():
            print(result.stderr.strip())
        return False

    return output_path.exists()


def main() -> int:
    if not GALLERY_JSON.exists():
        print(f'[thumbnail] Missing gallery manifest: {GALLERY_JSON}')
        return 1

    if not _openscad_available():
        print('[thumbnail] OpenSCAD is not installed; skipping thumbnail generation.')
        return 0

    with open(GALLERY_JSON, 'r', encoding='utf-8') as f:
        payload = json.load(f)

    panels = payload.get('panels', [])
    if not isinstance(panels, list) or not panels:
        print('[thumbnail] No panels found in gallery.json.')
        return 0

    updated = 0
    rendered = 0

    for panel in panels:
        if not isinstance(panel, dict):
            continue

        slug = str(panel.get('slug', '')).strip()
        scad_file = str(panel.get('scadFile', '')).strip()
        if not slug or not scad_file:
            continue

        scad_path = _resolve_local_scad_path(scad_file)
        if scad_path is None:
            print(f'[thumbnail] Skipping {slug}: SCAD source not local/available ({scad_file})')
            continue

        output_path = THUMB_DIR / f'{slug}.png'
        if not _render_thumbnail(scad_path, output_path):
            continue

        rendered += 1
        thumbnail_rel = f'images/panels/generated/{slug}.png'
        if panel.get('thumbnail') != thumbnail_rel:
            panel['thumbnail'] = thumbnail_rel
            updated += 1

    if updated:
        with open(GALLERY_JSON, 'w', encoding='utf-8') as f:
            json.dump(payload, f, indent=2)
            f.write('\n')

    print(f'[thumbnail] Rendered {rendered} thumbnails, updated {updated} manifest entries.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
