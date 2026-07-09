---
name: rvap-brand
description: >
  Applies the RVAP (Real Value Acceleration Program) brand identity — colors, fonts, logo,
  and layout patterns — consistently to any GitHub Pages website. Use this skill whenever
  someone asks to brand, rebrand, apply RVAP/RVAS visual identity, make a site look RVAP,
  match the brand kit, or transform a GitHub Pages site's look and feel to match RVAP.
  Also trigger when the user shares an HTML/CSS/MkDocs site and says it should look consistent
  with other RVAP/RVAS materials, even if they don't explicitly say "brand".
---

# RVAP Brand Application Skill

You have access to the complete RVAP brand kit extracted from `RVAP_brand_kit.pptx`. Your job
is to transform a GitHub Pages site (vanilla HTML/CSS, MkDocs, Jekyll, or similar) so that
it consistently uses the RVAP visual identity: colors, typography, logos, and component patterns.

**Before writing a single line of CSS or HTML**, read `references/brand-tokens.md` — it has every
hex value, font name, logo filename, and component recipe you will need. Then come back here for
the transformation workflow.

---

## Brand kit at a glance

| Element   | Value |
|-----------|-------|
| Primary   | RVAP Blue `#1A77E3` |
| Headings  | Deep Navy `#032254` |
| Body text | Charcoal `#47494E` |
| Accents   | Teal `#14868A` (Scale) · Purple `#504092` (Innovate) · MS Blue `#0078D4` (Build) |
| Surface   | White `#FFFFFF` · Light Neutral `#E3E6ED` · Surface `#F5F8FE` |
| Fonts     | Aptos Display (headings) / Aptos (body) — Inter/Outfit as web fallback |
| Logo dir  | `assets/logos/` relative to this SKILL.md |

---

## Step 1 — Understand the site

Before touching anything, map what you're working with:

1. **Identify the site generator**: Look for `mkdocs.yml` (MkDocs), `_config.yml` (Jekyll),
   or standalone HTML files. The transformation approach differs per type — see the sections below.
2. **Locate CSS entry points**: Find where fonts, colors, and layout are defined.
   In MkDocs Material sites this is `docs/stylesheets/extra.css` and `mkdocs.yml` `palette:` block.
   In custom HTML it is usually `assets/css/styles.css` or inline `<style>` blocks.
3. **Note the navigation structure**: You will need to add the RVAP logo to the header.
4. **Check for existing color values**: Quick-grep for any hardcoded hex colors so you know
   what needs replacing.

---

## Step 2 — Choose a transformation strategy

### Option A: Inject `brand.css` (fastest, non-destructive)

Copy `assets/brand.css` (next to this SKILL.md) into the site's assets, then add
`<link rel="stylesheet" href="<path>/brand.css">` as the **last** stylesheet in every HTML page.
The CSS custom properties and utility classes will overlay the existing theme.

Use this when:
- The existing CSS already uses CSS custom properties (`--color-*`, `--font-*`)
- You want a quick branded skin without restructuring

After injecting, you still need to manually fix elements that use hardcoded hex values or
`font-family` declarations that aren't reading from vars.

### Option B: Replace the token layer in-place (cleaner, recommended)

Open the main CSS file and replace the `:root { }` / token block with the RVAP tokens from
`assets/brand.css`. Then rename variables throughout if the site used a different naming scheme.

Use this when:
- The site already has a clean CSS variable system
- Variable names just need to be remapped to RVAP values

### Option C: Full restyle (MkDocs Material)

Edit `mkdocs.yml` to point at a new `extra.css`, then override the Material theme variables
with RVAP values. See the MkDocs section below.

---

## Step 3 — Apply brand colors

Replace the site's color scheme with the RVAP palette. The most common mappings:

| Old role              | RVAP replacement     | Hex       |
|-----------------------|----------------------|-----------|
| primary / accent      | RVAP Blue            | `#1A77E3` |
| secondary accent      | Microsoft Blue       | `#0078D4` |
| page background       | White                | `#FFFFFF` |
| card / panel surface  | Surface              | `#F5F8FE` |
| heading text          | Deep Navy            | `#032254` |
| body / paragraph text | Charcoal             | `#47494E` |
| muted / caption text  | Muted                | `#6B7280` |
| borders / dividers    | Light Neutral        | `#E3E6ED` |
| links                 | RVAP Blue            | `#1A77E3` |
| link hover            | Microsoft Blue       | `#0078D4` |
| hero background       | Gradient (Navy→Blue) | see `brand.css` `.rvap-hero` |

Do a global search-replace pass, then read through the result with fresh eyes to catch
anything you missed. Pay particular attention to `background-color`, `border-color`,
`color`, and SVG `fill`/`stroke` attributes.

**For MkDocs Material**, override these CSS variables in `extra.css`:
```css
:root {
  --md-primary-fg-color:         #1A77E3;
  --md-primary-fg-color--light:  #5B9BD5;
  --md-primary-fg-color--dark:   #032254;
  --md-accent-fg-color:          #0078D4;
  --md-default-fg-color:         #111827;
  --md-default-bg-color:         #FFFFFF;
  --md-typeset-color:            #47494E;
  --md-typeset-a-color:          #1A77E3;
  --md-code-bg-color:            #F5F8FE;
}
```

---

## Step 4 — Apply typography

### Web font loading

Add to the `<head>` of every HTML page (or to `extra_css` / `extra_javascript` in MkDocs):
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
```

Then declare the font stacks:
```css
:root {
  --font-display: "Aptos Display", "Outfit", "Segoe UI", system-ui, sans-serif;
  --font-body:    "Aptos", "Inter", "Segoe UI", system-ui, sans-serif;
}

body  { font-family: var(--font-body); }
h1, h2, h3, h4, h5 { font-family: var(--font-display); }
```

> Aptos is a Microsoft Office font (available on Windows/M365 machines as a system font).
> Outfit + Inter serve as the visual stand-in on other platforms. The result is visually
> identical on most user machines.

**For MkDocs Material** add to `mkdocs.yml`:
```yaml
extra_css:
  - stylesheets/brand.css   # your brand override file
theme:
  font:
    text: Inter
    code: JetBrains Mono
```

---

## Step 5 — Add the RVAP logo

Copy the appropriate logo file from the skill's `assets/logos/` directory into the site's
own assets folder (e.g., `docs/assets/` for MkDocs, `assets/img/` for custom HTML).

| Context                              | Logo file              | Background |
|--------------------------------------|------------------------|------------|
| Navigation bar / site header         | `logo-full.png`        | transparent — works on white/light nav |
| Hero section / landing page feature  | `logo-full.png`        | transparent — works on dark gradient hero |
| On white backgrounds (print, slides) | `logo-full-white.png`  | white bg baked in |
| Favicon / social preview image       | `logo-mark-white.png`  | white bg baked in |
| Watermark / transparent mark         | `logo-mark.png`        | transparent |

### In custom HTML — replace nav brand:
```html
<!-- Replace existing brand/logo element with: -->
<a class="brand" href="index.html" aria-label="Real Value Acceleration Program — Home">
  <img src="assets/img/logo-full.png" alt="RVAP" class="rvap-nav-logo" height="32">
</a>
```

### In MkDocs (`mkdocs.yml`):
```yaml
theme:
  name: material
  logo: assets/logos/logo-full.png
  favicon: assets/logos/logo-mark-white.png
```

---

## Step 6 — Component patterns

Apply these recurring RVAP components where the site has matching structures:

### Three-pillar layout (Build / Innovate / Scale)

If the site has any three-column or three-card feature section, map the columns to the
RVAP pillars with their accent colors. See `references/brand-tokens.md` → "Component patterns"
for the exact color values per pillar.

### Badge/pill labels
When tagging content with Build / Innovate / Scale, use the badge recipe from `brand.css`
(`.rvap-badge.build`, `.rvap-badge.innovate`, `.rvap-badge.scale`).

### Hero / banner
Replace any existing hero gradient with the RVAP navy-to-blue gradient
(`linear-gradient(135deg, #032254 0%, #0F3A7A 60%, #1A77E3 100%)`).

### Cards
Use `border-top: 3px solid <pillar color>` on content cards to signal which pillar they
belong to, with a light tinted surface behind (values in `brand-tokens.md`).

---

## Site-type playbooks

### MkDocs Material site

1. Copy brand assets into `docs/assets/logos/` and `docs/stylesheets/`
2. Update `mkdocs.yml`: logo, favicon, font, palette primary color
3. Create / update `docs/stylesheets/extra.css` with the token overrides from Step 3
4. Run `mkdocs build --strict` to validate. Fix any broken asset references.

### Custom HTML/CSS site (like `docs/` in this repo)

1. Copy `brand.css` into `docs/assets/css/brand.css`
2. Copy logo files into `docs/assets/img/`
3. Add `<link rel="stylesheet" href="assets/css/brand.css">` to the `<head>` of every page
4. Replace the `:root` variable block in the existing `styles.css` with RVAP tokens
5. Update the `<header>` to use the abbreviated logo image instead of any SVG/text mark
6. Search for hardcoded colors (`#`, `rgb(`, `hsl(`) in `.html` and `.css` files and replace
   with RVAP equivalents (see color table in Step 3)
7. Open in browser; visually check: nav, hero, cards, typography, links

### Jekyll / other static generators

Follow the same approach as custom HTML — locate the `_includes/` or `_layouts/` templates
for the header and edit those, then update the main SCSS/CSS file.

---

## Quality checklist

Before calling the transformation done, verify:

- [ ] All primary interactive elements (buttons, links) use RVAP Blue or Navy
- [ ] All headings use Deep Navy and the display font
- [ ] Body copy uses Charcoal and the body font
- [ ] The RVAP logo appears in the navigation header (abbreviated) and optionally hero (full)
- [ ] No legacy brand colors remain (no orange, green, yellow, or unrelated palettes)
- [ ] White/light-neutral backgrounds — no dark mode unless the user asked for it
- [ ] Cards and feature sections match the pillar accent colors if Build/Innovate/Scale content exists
- [ ] Contrast is maintained: dark text on light backgrounds, white text on navy/blue backgrounds
- [ ] Site still builds without errors

---

## What NOT to do

- Don't recolor the logo images — use them as-is (transparent PNGs)
- Don't use colors outside the RVAP palette unless the user explicitly asks (no random oranges, purples, etc. — Purple is specifically `#504092` for Innovate only)
- Don't place the chevron/blue logo over a saturated blue background
- Don't use the full logo in the navigation bar — abbreviated only

---

## Reference files in this skill

- `references/brand-tokens.md` — full color table, font stacks, logo specs, component recipes
- `assets/brand.css` — ready-to-inject CSS with all tokens + utility classes + components
- `assets/logos/logo-full.png` — full horizontal logo, transparent background (1058 × 376, RGBA)
- `assets/logos/logo-full-white.png` — full horizontal logo, white background (1254 × 406)
- `assets/logos/logo-mark-white.png` — square chevron mark, white background (1254 × 1254)
- `assets/logos/logo-mark.png` — standalone chevron mark, transparent background (1047 × 1015, RGBA)
