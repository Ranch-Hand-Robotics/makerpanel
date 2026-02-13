## Logo Setup Instructions

The Makerpanel website has been configured to use a custom logo.

### Current Status
⚠️ **Logo file needed**: `docs/images/makerpanel.jpg`

### What's Been Done
✅ Created `docs/images/` directory  
✅ Updated `mkdocs.yml` to use local logo instead of remote wrench icon  
✅ Configured both logo and favicon to use the same file  

### Next Steps for You

**If you have `makerpanel.jpg` in the repository root:**
```bash
git mv makerpanel.jpg docs/images/
git add docs/images/makerpanel.jpg
```

**If the file is on your local machine:**
1. Copy `makerpanel.jpg` to `docs/images/` directory
2. Add and commit:
```bash
git add docs/images/makerpanel.jpg
git commit -m "Add Makerpanel logo"
```

**To test the logo:**
```bash
mkdocs serve
```
Then visit http://localhost:8000 to see your logo in the header!

### Logo Specifications
- **Current path**: `docs/images/makerpanel.jpg`
- **Recommended size**: 100-200px square
- **Recommended format**: JPG, PNG, or SVG
- **Usage**: Site header logo and browser favicon
- **Theme compatibility**: Works with dark cyberpunk theme (neon green on dark backgrounds)

Once you add the file, the logo will automatically appear in:
- Website header/navigation bar
- Browser tab favicon
- Mobile home screen icon
