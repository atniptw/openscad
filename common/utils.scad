// Common utilities and shared variables
// Include this file at the top of your models:
//   include <../../common/utils.scad>

// ── Units ────────────────────────────────────────────────────────────────────
// All dimensions in millimeters

// ── Print tolerances ─────────────────────────────────────────────────────────
// Gap to add when two parts need to fit together (e.g., peg into a hole)
FIT_CLEARANCE = 0.2;  // mm

// Tolerance for press-fit / tight connections
PRESS_FIT = 0.1;  // mm

// ── Quality settings ─────────────────────────────────────────────────────────
// Override per-model if needed
$fn = $preview ? 32 : 128;  // Circle/sphere resolution

// ── Common layer heights ──────────────────────────────────────────────────────
LAYER_HEIGHT      = 0.2;   // standard
FIRST_LAYER       = 0.3;   // slightly thicker first layer
MIN_WALL          = 0.4;   // single extrusion width (0.4 mm nozzle)
