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
