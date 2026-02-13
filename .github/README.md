# Panel Submission Automation

This directory contains automation scripts for processing panel submissions from GitHub issues.

## Workflow: Process Panel Submission

**File**: `workflows/process-panel.yml`

### Purpose

Automates the process of adding a panel to the gallery from a GitHub issue created using the "Submit a Panel Design" template.

### How to Use

1. **User submits a panel** using the [panel submission form](https://github.com/Ranch-Hand-Robotics/makerpanel/issues/new/choose)
   - This creates a new issue with the `new-panel` label

2. **Maintainer reviews the submission**
   - Check that all required information is provided
   - Verify images are present and appropriate
   - Ensure the design meets specification requirements

3. **Run the workflow**
   - Go to [Actions → Process Panel Submission](https://github.com/Ranch-Hand-Robotics/makerpanel/actions/workflows/process-panel.yml)
   - Click "Run workflow"
   - Enter the issue number
   - Click "Run workflow"

4. **Automated processing**
   The workflow will:
   - ✅ Fetch the issue data
   - ✅ Parse all form fields
   - ✅ Download thumbnail and additional images
   - ✅ Create panel directory: `docs/panels/{panel-slug}/`
   - ✅ Generate panel markdown file: `docs/panels/{panel-slug}/panel.md`
   - ✅ Save images to: `docs/panels/{panel-slug}/images/`
   - ✅ Commit and push changes
   - ✅ Trigger the deployment workflow
   - ✅ Comment on the issue with success message
   - ✅ Close and label the issue as `processed`

### What Gets Created

For a panel named "Dual Potentiometer Control", the workflow creates:

```
docs/panels/dual-potentiometer-control/
├── panel.md              # Panel detail page
└── images/
    ├── thumb.png         # Thumbnail from issue
    ├── image-1.png       # Additional photos
    ├── image-2.png
    └── ...
```

### Manual Steps (if needed)

The workflow handles most tasks automatically, but you may want to:

1. **Review generated files** before they go live
   - Check `docs/panels/{panel-slug}/panel.md` for formatting
   - Verify images downloaded correctly

2. **Update gallery.md** (partially automated)
   - The script generates the panel card HTML
   - Manual integration into category tabs may be needed

3. **Handle edge cases**
   - Custom categories not in the standard list
   - Special formatting requirements
   - Large image files that need optimization

### Script: process_panel_issue.py

**File**: `scripts/process_panel_issue.py`

The Python script that does the heavy lifting:

- Fetches issue data from GitHub API
- Parses the issue form body
- Extracts images URLs and downloads them
- Generates panel markdown from template
- Creates proper directory structure
- Posts status comments to the issue

**Usage** (manual):
```bash
python .github/scripts/process_panel_issue.py <issue_number> <github_token>
```

### Environment Variables

The script uses these environment variables:

- `GITHUB_TOKEN` - GitHub API token (provided by workflow)
- `GITHUB_REPOSITORY` - Repository name (provided by workflow)
- `GITHUB_REPOSITORY_OWNER` - Repository owner (provided by workflow)

### Troubleshooting

**Issue not processed**
- Verify the issue has the `new-panel` label
- Check that all required fields are filled in
- Review workflow logs in Actions tab

**Images not downloading**
- Ensure images were uploaded to the issue (not linked externally)
- Check image URLs are in markdown format: `![alt](url)`

**Gallery not updating**
- Manual gallery.md update may be required
- Check the generated panel card HTML in workflow logs

**Deployment not triggered**
- Verify the deploy workflow has `workflow_dispatch` enabled
- Check permissions in workflow file

### Testing Locally

To test the script locally:

```bash
# Install dependencies
pip install requests

# Set environment variables
export GITHUB_TOKEN="your_personal_access_token"
export GITHUB_REPOSITORY="Ranch-Hand-Robotics/makerpanel"
export GITHUB_REPOSITORY_OWNER="Ranch-Hand-Robotics"

# Run the script
python .github/scripts/process_panel_issue.py <issue_number> $GITHUB_TOKEN
```

### Future Enhancements

- [ ] Fully automate gallery.md category tabs update
- [ ] Add image optimization (compress/resize)
- [ ] Validate specification compliance automatically
- [ ] Generate preview comment with rendered panel page
- [ ] Support for multiple panel submissions in one issue
- [ ] Automated tests for the processing script

## Contributing

Improvements to the automation workflow are welcome! Please test thoroughly before submitting PRs that modify the processing logic.
