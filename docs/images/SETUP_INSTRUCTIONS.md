## Logo Setup Instructions

The Makerpanel website has been configured to use a custom logo.

### Current Status
✅ **Temporary logo in place**: `docs/images/makerpanel.svg` (placeholder)  
📝 **Replace with your logo**: You can use JPG, PNG, or SVG format

### What's Been Done
✅ Created `docs/images/` directory  
✅ Updated `mkdocs.yml` to use local logo instead of remote wrench icon  
✅ Configured both logo and favicon to use the same file  
✅ Created temporary placeholder logo matching the cyberpunk theme  

### Next Steps for You

**If you have `makerpanel.jpg` in the repository root:**
```bash
# Move your logo and update config to use it
git mv makerpanel.jpg docs/images/
# Then update mkdocs.yml to point to makerpanel.jpg instead of makerpanel.svg
```

**If the file is on your local machine:**
1. Copy your logo to `docs/images/` directory
2. Update `mkdocs.yml` line 34-35 to use your filename (e.g., `makerpanel.jpg`, `makerpanel.png`)
3. Add and commit:
```bash
git add docs/images/makerpanel.jpg mkdocs.yml
git commit -m "Add custom Makerpanel logo"
```

**To test the logo:**
```bash
mkdocs serve
```
Then visit http://localhost:8000 to see your logo in the header!

### Logo Specifications
- **Current file**: `docs/images/makerpanel.svg` (temporary placeholder)
- **Accepts**: JPG, PNG, or SVG formats
- **Recommended size**: 100-200px square
- **Usage**: Site header logo and browser favicon
- **Theme compatibility**: Works with dark cyberpunk theme (neon green on dark backgrounds)

### Current Placeholder
The temporary `makerpanel.svg` logo features:
- Dark background (#1a1a1a) matching the site theme
- Neon green (#00ff00) wrench icon and "MP" text
- 200x200px size, perfect for header display

Replace it with your custom logo whenever you're ready!

Once you add your custom logo file, it will automatically appear in:
- Website header/navigation bar
- Browser tab favicon
- Mobile home screen icon
