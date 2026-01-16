# Makerpanel AI Coding Instructions

## Project Overview

**Makerpanel** is an open specification and gallery for modular maker panels. It's a documentation-driven project (not a code library) that defines technical standards for hardware panel design compatible with M-LOK rails—similar to Eurotrack synthesizer modules but generalized for maker applications.

**Key Architecture**:
- **MkDocs-based documentation**: All content is Markdown in the `docs/` folder
- **CI/CD pipeline**: GitHub Actions automatically builds and deploys to GitHub Pages on main branch push
- **Modular content structure**: Specification, gallery, contributing guide, and individual panel pages
- **Community-driven gallery**: User-submitted panel designs with standardized template format

## Critical Developer Workflows

### Documentation Build & Deployment

```bash
# Local preview (development)
mkdocs serve  # Runs at http://localhost:8000

# Production build
mkdocs build  # Generates static site in ./site/

# Dependencies installed via pip (see requirements.txt)
```

**Important**: The `deploy.yml` workflow automatically triggers on push to `main`. Any documentation changes must be validated locally first to avoid broken deployments.

### Adding Panel Designs to Gallery

1. **Follow the panel detail page template** in [docs/contributing.md](../docs/contributing.md)—this ensures consistency across all panels
2. **Three required file types**:
   - Thumbnail image: `docs/images/panels/{name}-thumb.{png|jpg|svg}` (400×400px minimum)
   - Detail page: `docs/panels/{name}.md` (Markdown with standardized sections)
   - Entry in `docs/gallery.md` using the panel-card div format
3. **Update gallery statistics** and category tabs when adding new panels

### Content Validation

- MkDocs config uses `strict: true` mode—all Markdown must be valid or build fails
- Navigation must be defined in `mkdocs.yml`—missing references prevent deployment

## Project-Specific Conventions

### Specification & Standards

The **Makerpanel Specification** defines universal mechanical/electrical standards:

- **Width in HP units**: 1 HP = 5.08 mm (common sizes: 4, 6, 8, 12, 16, 20, 24 HP)
- **Height**: 3U (128.5 mm) standard or 1U (44.45 mm) compact
- **Depth limit**: 60 mm max from front surface
- **Mounting**: M-LOK rail system (6.2 mm slots, 13 mm spacing for M3/M4 screws)
- **Compliance checklist** in spec must be verified for all submissions

### Gallery Organization

Panels are categorized by type: Analog Control, Visual Feedback, Connectivity, Digital I/O, Audio, Power. Each category has a tab in `gallery.md` using `pymdownx.tabbed` extension.

### Documentation Markdown Extensions

The project uses specific MkDocs extensions (see `mkdocs.yml`):
- `pymdownx.tabbed`: Category tabs in gallery
- `pymdownx.superfences`: Code blocks
- `pymdownx.highlight`: Syntax highlighting
- `tables`: Markdown tables for BOMs and specs
- `toc`: Table of contents with permalink generation

## Integration Points & Dependencies

### External Resources

- **GitHub Pages**: Deployment target; workflows publish to GitHub Pages environment
- **Material for MkDocs**: Referenced in docs but replaced with `readthedocs` theme in current config
- **Panel submission workflow**: Supports both pull requests (Git) and GitHub Issues for non-technical contributors

### File Dependencies

```
mkdocs.yml  ← Central config; defines nav, theme, markdown_extensions, strict mode
docs/index.md  ← Home page; links to spec, gallery, contributing
docs/specification.md  ← Defines all compliance standards; referenced by contributing guide
docs/gallery.md  ← Gallery index; must be updated when adding panels
docs/panels/{name}.md  ← Individual panel pages; follows strict template format
docs/images/panels/  ← Image assets; must match references in markdown
docs/contributing.md  ← Submission guide; includes panel template
.github/workflows/deploy.yml  ← Auto-deployment; triggers on main push
```

### Build Strictness & Validation

- Any broken internal link or missing navigation entry fails the build in CI
- New panels require entries in both `gallery.md` and navigation (if applicable) to deploy
- Image references must resolve or build fails

## Key Files for AI Agents

| File | Purpose |
|------|---------|
| [mkdocs.yml](../mkdocs.yml) | Build config; defines nav, theme, extensions, strict mode |
| [docs/specification.md](../docs/specification.md) | Master reference for all technical standards; **read before approving panel designs** |
| [docs/contributing.md](../docs/contributing.md) | Panel submission template and process; enforces consistency |
| [docs/gallery.md](../docs/gallery.md) | Gallery index; shows current panel count and categories |
| [docs/panels/pot-panel.md](../docs/panels/pot-panel.md) | Example panel with all required sections—use as template for new submissions |
| [workflows/deploy.yml](workflows/deploy.yml) | CI/CD pipeline; understand for release coordination |

## Common Tasks & Patterns

### Reviewing a Panel Submission

1. **Verify specification compliance** using the checklist in [docs/specification.md](../docs/specification.md)
2. **Check template adherence**: Ensure all sections from [docs/contributing.md](../docs/contributing.md) panel template are present
3. **Validate image paths**: Images must exist in `docs/images/panels/` and reference correctly
4. **Confirm gallery updates**: Panel must be added to `docs/gallery.md` with matching filename and category
5. **Test build locally**: `mkdocs build` to catch broken links before merge

### Adding New Specification Sections

- Update `docs/specification.md` with clear rationale
- Include concrete examples or reference designs
- Verify related docs (e.g., `contributing.md`) still make sense
- Test build; reference changes often break existing panels

### Community Interaction Pattern

Contributors use Pull Requests (experienced) or GitHub Issues (casual). **Issue submissions require manual integration by maintainers**—extract files, create PR, and ensure all documentation follows existing patterns.

## Architecture Rationale

This is intentionally a **documentation project, not a software library**:
- Makerpanel is a *specification standard*, not code to be installed
- MkDocs chosen for simplicity, visibility, and ease of community contribution
- Panel designs are *example implementations*, not enforced
- Flexibility explicitly encouraged (custom heights, integrated systems, powered rails)—documentation reflects this
