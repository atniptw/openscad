// RIZZARI gravity pet water dispenser — reference prop model
// Overall: 12.8" L × 7.3" W × 13.8" H  →  325 × 185 × 351 mm
//
// Geometry:
//   - Stainless steel bowl: oblong/oval base, low walls, open top
//   - Plastic jug: cylindrical body, inverted — neck points down into bowl
//   - Valve/cap at neck seats into a hole in the bowl floor
//
// This file is a visual reference only. No printable parts here.

include <../../common/utils.scad>

// ── Overall dimensions (mm) ───────────────────────────────────────────────────
total_l   = 325;   // bowl length (X)
total_w   = 185;   // bowl width  (Y)
total_h   = 351;   // full height including jug

// ── Jug ───────────────────────────────────────────────────────────────────────
jug_od        = 130;   // outer diameter of cylindrical jug body
jug_wall      =   3;   // plastic wall thickness
jug_body_h    = total_h - 60;  // height above bowl
jug_neck_od   =  32;   // neck that inserts into valve seat
jug_neck_h    =  30;   // length of neck

// ── Bowl geometry ────────────────────────────────────────────────────────────
// The bowl is a curved cradle that the jug rests in, with a flat rim ledge
// Cross-section: curved bottom + flat rim at top
bowl_h        =  50;   // total height
bowl_rim_h    =  10;   // height of the flat rim ledge
bowl_cradle_h = bowl_h - bowl_rim_h;  // curved cradle part
bowl_w        = jug_od + 40;  // width wider than jug body
bowl_l        = jug_od * 2.5; // length = 2.5 jugs
bowl_wall     =   3;   // wall thickness
bowl_rim_w    =  20;   // width of the flat rim ledge on each side

// ── Helpers ───────────────────────────────────────────────────────────────────

// Stadium shape: rectangle with rounded ends (oval-ish)
// lx = length (long axis), ly = width (short axis), h = height, r = corner radius
module rounded_box(lx, ly, h, r) {
    // Hull of four cylinders at corners + edges creates proper stadium shape
    hull() {
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * (lx / 2 - r), sy * (ly / 2 - r), 0])
                    cylinder(h = h, r = r, $fn = $fn);
    }
}

// ── Bowl module ────────────────────────────────────────────────────────────────
// Oval-shaped tray: straight long sides, rounded ends
module bowl() {
    color("Silver")
    difference() {
        // Outer shell: stadium shape (oval)
        rounded_box(bowl_l, bowl_w, bowl_h, bowl_rim_w);
        
        // Inner hollow: slightly smaller stadium
        translate([0, 0, bowl_wall])
            rounded_box(bowl_l - bowl_wall * 2, bowl_w - bowl_wall * 2, bowl_h, bowl_rim_w - bowl_wall);
    }
}

// ── Jug module (rendered upright, open end at top) ────────────────────────
// Origin at the closed BOTTOM
module jug_upright() {
    color([0.85, 0.92, 1.0, 0.6]) {
        // Closed flat bottom
        cylinder(h = 5, r = jug_od / 2, $fn = $fn);
        // Cylindrical body
        translate([0, 0, 5])
            cylinder(h = jug_body_h - jug_neck_h - 30 - 5, r = jug_od / 2, $fn = $fn);
        // Shoulder taper from body to neck
        translate([0, 0, jug_body_h - jug_neck_h - 30])
            cylinder(h = 30, r1 = jug_od / 2, r2 = jug_neck_od / 2, $fn = $fn);
        // Open neck pointing UP
        translate([0, 0, jug_body_h - jug_neck_h])
            cylinder(h = jug_neck_h, r = jug_neck_od / 2, $fn = $fn);
    }
    // Valve cap at the open neck top
    color("DarkGray")
        translate([0, 0, jug_body_h])
            cylinder(h = 8, r = jug_neck_od / 2 + 2, $fn = $fn);
}

// ── Scene ─────────────────────────────────────────────────────────────────────
// Bowl sitting on the floor
bowl();

// Jug inverted: sits LOW so wide body rests ON the bowl rim, neck hangs deep into bowl
jug_x_offset = 55;   // offset to position jug at one end completely
translate([jug_x_offset, 0, bowl_h - 15])  // body rests on rim, neck goes down into bowl
    rotate([180, 0, 0])
        translate([0, 0, -jug_body_h])
            jug_upright();
