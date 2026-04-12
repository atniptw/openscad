# OpenSCAD 3D Models

A collection of parametric 3D models designed for FDM printing, built with [OpenSCAD](https://openscad.org).

## Directory structure

```
├── common/          # Shared variables and utilities (include in your models)
└── models/
    ├── _template/   # Copy this to start a new model
    ├── cable-clip/   # Desk cable clip
    ├── lid-rack/     # Kitchen cabinet water bottle lid organiser
    └── ramp-railing/ # Modular side railing for a dog ramp
```

## Creating a new model

```bash
cp -r models/_template models/<my-model>
```

Edit `models/<my-model>/model.scad` and add at the top:

```scad
include <../../common/utils.scad>
```

## Rendering

Preview in the GUI:

```bash
openscad models/cable-clip/cable-clip.scad
```

Render a PNG without a display (headless / CI):

```bash
LIBGL_ALWAYS_SOFTWARE=1 openscad --render --imgsize=800,600 --autocenter --viewall --colorscheme=Tomorrow \
  -o models/cable-clip/cable-clip.png models/cable-clip/cable-clip.scad
```

Export to STL for slicing:

```bash
openscad -o models/cable-clip/cable-clip.stl models/cable-clip/cable-clip.scad
```

Override parameters from the command line:

```bash
openscad -D "cable_diameter=8" -o out.stl models/cable-clip/cable-clip.scad
```

## Creality Defaults and User Presets

Use the helper script to extract effective default machine/process/filament settings from Creality Print and create new User preset files:

```bash
./scripts/creality_presets.py \
    --apply \
    --snapshot-out profiles/creality/ender3-v3-ke-defaults.json \
    --preset-suffix "User Baseline"
```

Notes:
- Without `--apply`, the script runs in dry-run mode.
- By default it targets profile version `7.0` and machine `Creality Ender-3 V3 KE 0.4 nozzle`.
- It writes User presets to Creality's `user/default/{machine,process,filament}` directories.

To create a preset that is clearly visible in dropdowns, add at least one override and mark it custom-defined:

```bash
./scripts/creality_presets.py \
    --apply \
    --custom-defined \
    --create-process \
    --preset-suffix "Visible Test" \
    --process-override outer_wall_speed=180
```

To create and immediately select the generated preset in Creality Print:

```bash
./scripts/creality_presets.py \
    --apply \
    --create-process \
    --preset-suffix "Auto Select" \
    --process-override outer_wall_speed=165 \
    --select-created
```
