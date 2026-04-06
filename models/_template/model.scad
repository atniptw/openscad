// Template for a new model project.
// Copy this directory to models/<your-model-name>/ and rename accordingly.
//
// Usage: openscad -o output.stl <model>.scad

include <../../common/utils.scad>

// ── Parameters ────────────────────────────────────────────────────────────────
// Expose dimensions as variables so they can be overridden from the CLI:
//   openscad -D "width=40" -o output.stl model.scad

width  = 30;  // mm
depth  = 20;  // mm
height = 10;  // mm

// ── Model ─────────────────────────────────────────────────────────────────────
cube([width, depth, height]);
