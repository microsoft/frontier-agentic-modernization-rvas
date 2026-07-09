# RVAP Brand — Complete Token Reference

Sourced from: `RVAP_brand_kit.pptx` (14-slide internal working draft)

---

## Color Palette (slide 5)

| Token name        | Hex       | Role                                      |
|-------------------|-----------|-------------------------------------------|
| RVAP Blue         | `#1A77E3` | **Primary** – buttons, links, key UI      |
| Microsoft Blue    | `#0078D4` | Build pillar; Microsoft platform identity |
| Deep Navy         | `#032254` | Headings, emphasis, hero backgrounds      |
| Charcoal          | `#47494E` | Body text, secondary copy                 |
| Teal              | `#14868A` | **Scale** accent                          |
| Purple            | `#504092` | **Innovate** accent                       |
| Light Neutral     | `#E3E6ED` | Dividers, borders, subtle backgrounds     |
| White             | `#FFFFFF` | Page background, card fills               |

### Supporting values (pulled from slide layouts)

| Hex       | Seen as                                   |
|-----------|-------------------------------------------|
| `#111827` | near-black text (slide body copy)         |
| `#47494E` | charcoal (same as above)                  |
| `#6B7280` | muted / de-emphasized text                |
| `#F5F8FE` | very light blue-white surface             |
| `#FAFBFD` | alternate surface                         |
| `#DDE6F7` | navy-tinted light surface                 |
| `#DDE3EF` | teal-tinted light surface                 |

### Usage guidance (slide 5)
- **Primary**: RVAP Blue + Charcoal
- **Foundation**: Deep Navy for emphasis and technical depth
- **Solution accents**: Teal for Scale, Purple for Innovate, Navy/MS-Blue for Build
- **Neutral**: Light Neutral + White for clean Microsoft-style layouts

---

## Typography (slide 6)

| Font             | Role                                              | CSS stack                                   |
|------------------|---------------------------------------------------|---------------------------------------------|
| Aptos Display    | Large titles, section openers, program positioning | `"Aptos Display", "Outfit", "Segoe UI", system-ui, sans-serif` |
| Aptos            | Body copy, details, tables, operational templates  | `"Aptos", "Inter", "Segoe UI", system-ui, sans-serif` |

> **Web delivery note**: Aptos is a Microsoft Office font. On Windows/Microsoft 365 machines it's available as a system font. For public web, use Google Fonts `Outfit` (display) and `Inter` (body) as the web fallback — the `brand.css` already handles this with `@import`.

### Hierarchy example (slide 6)
```
RVAP Control Tower in Fabric               ← Aptos Display, large title, Deep Navy
Real Value Acceleration Solution           ← Aptos Display, subtitle, RVAP Blue
A packaged delivery motion…                ← Aptos, body, Charcoal
Build → Innovate → Scale                   ← Aptos, small label, muted
```

---

## Logo Assets (assets/logos/)

| File                    | Dimensions  | Background  | Use case                                                          |
|-------------------------|-------------|-------------|-------------------------------------------------------------------|
| `logo-full.png`         | 1058 × 376  | Transparent | Nav bars, hero banners, any colored/gradient background           |
| `logo-full-white.png`   | 1254 × 406  | White       | Print, slides, email — when transparent PNG isn't supported       |
| `logo-mark-white.png`   | 1254 × 1254 | White       | Favicons, social cards, square avatar contexts                    |
| `logo-mark.png`         | 1047 × 1015 | Transparent | Watermarks, overlays, small square containers on light backgrounds|

All logos are RGBA PNGs (transparent background).

### Logo rules (slides 3, 4, 9)
- **Minimum digital size**: full logo ≥ 600 px wide; use abbreviated for anything smaller
- **Clear space**: maintain at least the height of the "A" counter / chevron gap around the logo
- **Backgrounds**: clean white or very light backgrounds only; avoid placing the blue chevron over saturated blue
- **Never**: stretch/skew, recolor ad hoc, crowd with other marks inside the clear space
- **Always**: scale uniformly; maintain contrast

---

## Brand Messaging (slides 7, 14)

**Program name**: Real Value Acceleration Program (RVAP)  
**Solution system name**: RVAS (Real Value Acceleration Solution)

**Naming convention for solutions**: `RVAS – [Outcome / Scenario]`  
Examples: RVAS – Control Tower in Fabric · RVAS – AI Governance with Foundry · RVAS – Agentic SDLC

**Three pillars**:
| Pillar    | Color  | Theme                                              |
|-----------|--------|----------------------------------------------------|
| Build     | #0078D4| Create targeted technical artifacts, reusable patterns |
| Innovate  | #504092| Apply AI, data and agentic patterns                |
| Scale     | #14868A| Package repeatable solutions for customers/field   |

**Tagline**: *Build. Innovate. Scale real value.*

**Brand promise**: Accelerate real value with packaged, reusable, technically credible solutions for common customer challenges.

---

## Component patterns (from brand kit slides)

### Card with pillar accent
Top border color signals which pillar the content belongs to:
- Build: `#0078D4` top border, `#DDE6F7` surface
- Innovate: `#504092` top border, `#EDE9F7` surface
- Scale: `#14868A` top border, `#DDE3EF` surface

### Navigation / header
- Background: white, 1px `#E3E6ED` bottom border
- Logo: `logo-full.png` (transparent), 32px height
- Links: Aptos, 14px, Charcoal; hover RVAP Blue

### Hero / banner
- Background: gradient `#032254` → `#0F3A7A` → `#1A77E3`
- Text: white; eyebrow label in uppercase, 70% opacity white

### Badge / pill labels
- Build: `#DDE6F7` bg, `#0078D4` text
- Innovate: `#EDE9F7` bg, `#504092` text
- Scale: `#DDE3EF` bg, `#14868A` text
