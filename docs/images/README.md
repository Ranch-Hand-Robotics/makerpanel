# Images Directory

This directory contains images used across the Makerpanel documentation.

## Logo Configuration

The site is configured to use `makerpanel.jpg` as the logo and favicon.

### Adding the Logo

If you have `makerpanel.jpg` in the repository root, move it here:
```bash
mv makerpanel.jpg docs/images/
```

Or if you're adding it for the first time, place it in `docs/images/makerpanel.jpg`.

The logo is configured in `mkdocs.yml`:
- `logo: images/makerpanel.jpg` - Displays in the site header
- `favicon: images/makerpanel.jpg` - Shows in browser tabs

### Logo Recommendations

For best results:
- **Format**: JPG, PNG, or SVG
- **Size**: 100-200px square recommended
- **Background**: Transparent or white works best with dark theme
- **File size**: Keep under 100KB for fast loading
