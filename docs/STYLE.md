# Memoirs of Technoir — Style Guide

Source of truth distilled from the Figma board *Memoirs of Technoir* and the Godot prototype. Use this when adding chapters, UI, environments, models, or audio.

## Product tone

- Soft, curious, encouraging — never punishing.
- Indonesian-first voice: warm, slightly literary in story panels; clear and short in UI.
- Growth story: an under-acknowledged girl becoming a real mechanic through patient hands-on work.
- Webtoon story → staged 3D repair. Not arcade; not dark cyberpunk despite the title.

## Color

| Token | Hex | Use |
|-------|-----|-----|
| Cream | `#F7F1E8` | Main menu / chapter select backgrounds |
| Cream deep | `#EDE4D6` | Cards, secondary surfaces |
| Brass | `#C4A35A` | Logo, metallic accents, battery, hubs |
| Brass dark | `#8B7340` | Logo stroke depth |
| Ink | `#2C2416` | Primary text on cream |
| Ink soft | `#5C5346` | Secondary text |
| Night deep | `#0E1628` | Prologue / night story bg |
| Night | `#1A2744` | Night panels / ambient |
| Warm lamp | `#E8B86D` | Night desk key light / emission |
| Accent orange | `#E8A87C` | Soft chapter-select shapes |
| Pill | `#2A2A2A` | Primary CTA buttons |

Avoid default “AI purple,” harsh neon glow, and cold pure-white UI chrome.

## Typography

- Titles / story: serif feel (Georgia-like). Large, centered on splash; literary on webtoon.
- UI labels: clean sans (Godot default OK for prototype). Keep CTAs short.
- Hierarchy: brand name is hero-level on splash; chapter titles must not overpower the hero object.

## Layout patterns (from Figma)

1. **Splash** — white/cream, centered brass logo, serif title, soft load.
2. **Chapter select** — soft curved color field, large hero object (cassette/fan), pill CTA, page dots.
3. **Story webtoon** — vertical scroll, illustration + Indonesian prose blocks, CTA into repair.
4. **Workbench** — object center stage, tools bottom, optional dialogue bubble, optional blueprint wash.
5. Portrait mobile frame (~412×917). Stretch with `keep_width`.

## 3D / environments

- **Ch1 night desk:** warm lamp key, cool blue fill, wood table, quiet clutter energy (minimal geometry OK).
- **Ch2 day window / stage:** brighter cream-orange backdrop, clearer read on black fan — Figma chapter-card energy, not full AR camera.
- Materials: soft metal + matte plastic; Compatibility renderer friendly (simple albedo/metallic/roughness).
- Interaction readability > photorealism.

## Interaction language

- Screwdriver removes fasteners; hand pulls parts that are free.
- Soft snap SFX on detach/attach; success chime when function runs.
- Objects must **run** after correct assembly (spin / audio loop).
- Orbit: drag empty space; pick parts by direct tap.

## Audio

- BGM: soft pad / lo-fi warmth, low presence, loop forever.
- SFX: short, gentle — screw turn, snap out/in, UI tap, success chime.
- Buses: `BGM`, `SFX` under Master; user sliders in Settings.

## Content authoring

- New chapter = `content/chapters/<id>.json` + story images + unlock wiring.
- New object = `content/objects/<id>.json` part graph + `function` block.
- Strings in `content/locale/id.json`.
- Shop mode stub: `content/modes/shop.json` (`enabled: false`) — do not build until main path is solid.

## Do / Don’t

**Do**
- Keep cream + brass + night lamp as the signature triad.
- Prefer one hero object per screen.
- Write Indonesian story copy before English.

**Don’t**
- Clutter the first viewport with stats/schedules.
- Use harsh fail states or timed punishment.
- Add shop/queue gameplay before chapter repair loop feels good.
- Ship Forward+/Mobile-only materials that break Web (Compatibility) export.
