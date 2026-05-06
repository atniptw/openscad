# OpenSCAD Models — Claude Code Instructions

## Documentation

Always consult the official OpenSCAD documentation before writing or modifying `.scad` files:
- **Full manual**: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual
- **Language reference**: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language
- **Cheat sheet**: https://www.openscad.org/cheatsheet/

Fetch the relevant manual page for any language feature before using it. Do not guess syntax.

## Repository structure

- `common/utils.scad` — shared constants (tolerances, `$fn`, layer heights). Include in every model.
- `models/_template/` — starter template; copy to `models/<name>/` for new models.
- `models/<name>/` — one directory per model project.

## Rendering

Render a PNG for review (headless, no display required):

```bash
LIBGL_ALWAYS_SOFTWARE=1 openscad --render --imgsize=800,600 --autocenter --viewall --colorscheme=Tomorrow \
  -o <model>.png <model>.scad
```

Export STL for slicing:

```bash
openscad -o <model>.stl <model>.scad
```

## .scad conventions

- All units in **millimeters**.
- Expose all meaningful dimensions as top-level variables so they can be overridden with `-D` on the CLI.
- Use `$fn = $preview ? 32 : 128;` (already in `utils.scad`) — do not hardcode `$fn` in models.
- Use `FIT_CLEARANCE` and `PRESS_FIT` from `utils.scad` instead of magic numbers for tolerances.
- Do not commit rendered `.stl`, `.png`, or other output files (covered by `.gitignore`).
