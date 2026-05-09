// Cat water bottle collar with locking tabs
// A ring snaps around the bottle at its narrowest point.
// Two downward tabs slot into a printed base-ring that sits around the bowl.
// Rotate the bottle ~30° to lock/unlock — cats can't do that.
//
// Print two pieces:
//   PIECE A — base ring (goes around the bowl)
//   PIECE B — bottle collar (clamps on the bottle, has locking tabs)
//
// Usage: openscad -o 02-locking-collar.stl 02-locking-collar.scad

include <../../common/utils.scad>

// ── Parameters ────────────────────────────────────────────────────────────────
bowl_od          = 160;   // outer diameter of the metal bowl
bowl_h           =  40;   // height of the metal bowl (base ring wraps it)

bottle_od        =  80;   // outer diameter of bottle at collar position
collar_h         =  30;   // height of the bottle collar ring

wall             =   3;   // printed wall thickness
tab_w            =  12;   // width of each locking tab
tab_h            =  20;   // how far the tab extends downward from collar
tab_depth        =   6;   // tab thickness (radial)
lock_angle       =  30;   // rotation needed to lock/unlock

num_tabs         =   2;   // number of tabs (evenly spaced)

// ── Derived ───────────────────────────────────────────────────────────────────
collar_id = bottle_od + FIT_CLEARANCE * 2;
collar_od = collar_id + wall * 2;

base_id = bowl_od + FIT_CLEARANCE * 2;
base_od = base_id + wall * 2 + tab_depth;

// ── Modules ───────────────────────────────────────────────────────────────────

// PIECE A — base ring
// Sits around the bowl. Has J-shaped or L-shaped slots for the tabs.
module base_ring() {
    difference() {
        // Solid ring
        cylinder(h = bowl_h, r = base_od / 2, $fn = $fn);
        // Hollow for bowl
        translate([0, 0, -1])
            cylinder(h = bowl_h + 2, r = base_id / 2, $fn = $fn);
        // Tab slots — vertical entry channel + rotated lock pocket
        for (i = [0 : num_tabs - 1]) {
            rotate([0, 0, i * (360 / num_tabs)]) {
                // Vertical entry slot (tab drops straight in)
                translate([base_id / 2 + tab_depth / 2, -tab_w / 2, bowl_h - tab_h - 1])
                    cube([tab_depth + 2, tab_w, tab_h + 2]);
                // Horizontal lock pocket (rotated by lock_angle) at bottom of slot
                rotate([0, 0, lock_angle / 2])
                    translate([base_id / 2 + tab_depth / 2, -tab_w / 2, bowl_h - tab_h - 1])
                        cube([tab_depth + 2, tab_w, wall * 2]);
            }
        }
    }
}

// PIECE B — bottle collar
// Clamps around the bottle. Has tabs that drop into the base ring slots.
module bottle_collar() {
    union() {
        // Main collar ring
        difference() {
            cylinder(h = collar_h, r = collar_od / 2, $fn = $fn);
            translate([0, 0, -1])
                cylinder(h = collar_h + 2, r = collar_id / 2, $fn = $fn);
        }
        // Locking tabs hanging down from the collar bottom
        for (i = [0 : num_tabs - 1]) {
            rotate([0, 0, i * (360 / num_tabs)])
                translate([collar_id / 2 + FIT_CLEARANCE, -tab_w / 2, -tab_h])
                    cube([tab_depth, tab_w, tab_h]);
        }
    }
}

// ── Render (side by side for preview) ────────────────────────────────────────
// Base ring on the left
translate([-base_od - 10, 0, 0])
    base_ring();

// Bottle collar on the right
translate([collar_od + 10, 0, collar_h])   // flip upside down to show tabs
    rotate([180, 0, 0])
        bottle_collar();
