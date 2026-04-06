# OpenSCAD 3D Models

A collection of parametric 3D models designed for FDM printing, built with [OpenSCAD](https://openscad.org).

## Directory structure

```
├── common/          # Shared variables and utilities (include in your models)
└── models/
    ├── _template/   # Copy this to start a new model
    └── cable-clip/  # Example: desk cable clip
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

Export to STL for slicing:

```bash
openscad -o models/cable-clip/cable-clip.stl models/cable-clip/cable-clip.scad
```

Override parameters from the command line:

```bash
openscad -D "cable_diameter=8" -o out.stl models/cable-clip/cable-clip.scad
```
