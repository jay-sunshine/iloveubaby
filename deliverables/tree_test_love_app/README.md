# Tree Test Love App

## Isolated scene
- Main presentation scene: `E:\山河志风起汉末\scenes\tree_test_love_app.tscn`
- Original `E:\山河志风起汉末\scenes\tree_test.tscn` is left untouched.

## What changed
- Added a large spherical ocean shell to soften the horizon and help sea/sky blend.
- Switched this isolated scene to a touch-friendly orbit camera for phone/tablet/desktop presentation.

## Best sharing target
1. Web export: best for both phone and computer because it opens in a browser.
2. Windows desktop export: easiest local EXE if you only need PC.
3. Android export: possible, but needs Android export templates + SDK setup.

## Current blocker on this machine
- No Godot export templates were found under `C:\Users\Admin\AppData\Roaming\Godot\export_templates`.
- Because of that, the scene is ready, but a final `.exe`, `.html`, or `.apk` has not been built yet in this session.

## Next export step when templates are installed
1. Open the project in Godot 4.6.1.
2. Use the isolated scene `res://scenes/tree_test_love_app.tscn` as the presentation entry scene for export.
3. Export Web first if you want one link/package that works on both phone and computer.
4. Export Windows desktop as a backup offline package.

## Recommended delivery idea
- Best: export Web and host it, then send her a link.
- Backup: export Windows desktop and send a zip.
- If you only need a one-shot visual gift, capture a hero screenshot plus a short Web/desktop build.

## GitHub Pages path added in repo
- Workflow: `E:\山河志风起汉末\.github\workflows\love_web_pages.yml`
- Web preset: `E:\山河志风起汉末\export_presets.cfg`
- CI-only scene switcher: `E:\山河志风起汉末\tools\export\prepare_love_web.py`

## How to get the link
1. Mirror or push this repository to GitHub.
2. In GitHub repo settings, enable Pages with GitHub Actions.
3. Push to `main` or `master`, or manually run the `Love Web Pages` workflow.
4. After Actions finishes, GitHub Pages will give you a URL you can send directly.

## What this setup does
- Keeps your local main game entry untouched during normal work.
- In CI only, rewrites `run/main_scene` to `res://scenes/tree_test_love_app.tscn`.
- Exports a Web build and deploys only that isolated confession scene to Pages.
