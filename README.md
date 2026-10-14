# Memoirs of Technoir

Soft, story-driven mechanic-learning game (Indonesian-first). Built with **Godot 4** using the **Compatibility** renderer so the same project exports to **Android** and **HTML5** (browser touch preview).

Figma direction: cream/brass UI, webtoon prologue, staged 3D repair table.

## Requirements

- [Godot 4.3+](https://godotengine.org/download/) **standard** build (not .NET required)
- For browser build: Web export templates (Editor → Manage Export Templates)
- For Android: Android export templates + JDK/SDK (optional for prototype)

## Run in editor (fastest)

1. Open `project.godot` in Godot 4
2. Confirm **Renderer: gl_compatibility** (Project Settings → Rendering)
3. Press **F5** (main scene: `scenes/boot/Boot.tscn`)

### Demo path

Boot → Main → Chapters → **Chapter 1** story (night desk) → workbench cassette → unscrew → pull door/battery → reassemble → **Nyalakan** → unlock Chapter 2 → fan repair → spin.

Tools: **Obeng** for screws, **Tangan** for parts. Drag empty viewport to orbit.

## Browser “emulator” (HTML5)

Godot 4.7+ with Web export templates installed (already used to produce `build/web/` in this workspace when templates are present).

```powershell
# Serve the existing build:
powershell -File tools/serve_web.ps1

# Re-export then serve (GODOT on PATH or -Godot path\to\godot.exe):
powershell -File tools/serve_web.ps1 -Export
```

Then open `http://127.0.0.1:8060/` on a touch laptop or with DevTools device mode.

Editor-only play (no export): open `project.godot` → **F5**.

Linux/mac: `tools/serve_web.sh` / `tools/serve_web.sh --export`

## Project layout

| Path | Role |
|------|------|
| `content/chapters/` | Chapter JSON (story, unlocks, env) |
| `content/objects/` | Repairable part graphs + functions |
| `content/locale/id.json` | Indonesian strings |
| `content/modes/shop.json` | Future shop minigame stub |
| `scenes/` | Boot, Main, Chapters, Settings, Story, Workbench |
| `scripts/` | Autoloads + UI/repair logic |
| `docs/STYLE.md` | Art/UX language for expansion |
| `.cursor/skills/technoir-*` | Agent skills for content/repair/UI |

## Scalability

Add a chapter without touching engine code:

1. `content/chapters/ch03_….json`
2. Strings in `content/locale/id.json`
3. Object JSON + mesh ids in `MeshFactory` if new shapes
4. Set previous chapter `"unlocks": "ch03_…"`

## Style

See [docs/STYLE.md](docs/STYLE.md).

## License

See [LICENSE](LICENSE). Replace audio/models with your licensed assets before store release; prototype ships procedural meshes + synthesized soft SFX/BGM.
