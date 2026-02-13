# Images Directory

This directory contains images used across the Makerpanel documentation.

## Logo Configuration

The site is configured to use `makerpanel.svg` as the logo and favicon.

### Adding Your Custom Logo

If you have `makerpanel.jpg` in the repository root, move it here and update the config:
```bash
mv makerpanel.jpg docs/images/
# Then update mkdocs.yml lines 34-35 to reference makerpanel.jpg
```

Or if you're adding it for the first time:
1. Place your logo file in `docs/images/` (as `makerpanel.jpg`, `makerpanel.png`, or other format)
2. Update `mkdocs.yml` lines 34-35 to reference your filename

The logo configuration in `mkdocs.yml`:
```yaml
logo: images/makerpanel.svg  # Update to your filename
favicon: images/makerpanel.svg  # Update to your filename
```

### Logo Recommendations

For best results:
- **Format**: JPG, PNG, or SVG
- **Size**: 100-200px square recommended
- **Background**: Transparent or white works best with dark theme
- **File size**: Keep under 100KB for fast loading
