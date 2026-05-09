// Cat water bottle hook clip
// Hooks under the bowl rim, upper arm grips the bottle body.
// Squeeze the arms together to release; lift bottle straight up to refill.
//
// Usage: openscad -o 01-hook-clip.stl 01-hook-clip.scad

include <../../common/utils.scad>

// ── Parameters ────────────────────────────────────────────────────────────────
bowl_od          = 160;   // outer diameter of the metal bowl
bowl_rim_h       =   8;   // height of the bowl rim wall
bowl_rim_thick   =   2;   // thickness of the bowl rim wall

bottle_od        =  80;   // outer diameter of bottle at grip point
bottle_grip_h    =  30;   // vertical height the saddle wraps around

wall             =   3;   // printed wall thickness
clip_gap         =   2;   // gap so the hook slides over the rim (adjust to fit)
arm_length       =  50;   // length of arm from bowl hook to bottle saddle

// ── Derived ───────────────────────────────────────────────────────────────────
hook_id  = bowl_rim_thick + clip_gap + FIT_CLEARANCE;
hook_h   = bowl_rim_h * 0.7;   // hook engages lower portion of rim

saddle_r = bottle_od / 2 + FIT_CLEARANCE;

// ── Modules ───────────────────────────────────────────────────────────────────

// Downward hook that catches under the bowl rim
module bowl_hook() {
    // Outer vertical back
    cube([wall, wall + hook_id + wall, bowl_rim_h + wall]);
    // Horizontal inward tooth at bottom
    translate([0, 0, 0])
        cube([wall, wall, bowl_rim_h + wall]);   // back wall (included above)
    // Inward horizontal shelf
    translate([0, wall, 0])
        cube([wall, hook_id, wall]);
}

// Half-saddle that wraps around the bottle
module bottle_saddle_half() {
    wrap_angle = 120;   // degrees of wrap per half
    difference() {
        cylinder(h = bottle_grip_h, r = saddle_r + wall, $fn = $fn);
        // hollow out
        cylinder(h = bottle_grip_h, r = saddle_r, $fn = $fn);
        // cut to half + wrap_angle/2
        rotate([0, 0, wrap_angle / 2])
            translate([-saddle_r * 2, 0, -1])
                cube([saddle_r * 4, saddle_r * 4, bottle_grip_h + 2]);
        // mirror cut
        rotate([0, 0, 180 - wrap_angle / 2])
            translate([-saddle_r * 4, 0, -1])
                cube([saddle_r * 4, saddle_r * 4, bottle_grip_h + 2]);
    }
}

// Arm connecting hook to saddle
module arm() {
    cube([arm_length, wall, wall]);
}

// ── Assembly ──────────────────────────────────────────────────────────────────
// Bowl hook at origin
bowl_hook();

// Arm running outward from hook
translate([0, wall / 2, bowl_rim_h])
    arm();

// Bottle saddle at end of arm, centred on arm width
translate([arm_length, 0, bowl_rim_h])
    rotate([0, 0, 90])
        bottle_saddle_half();
