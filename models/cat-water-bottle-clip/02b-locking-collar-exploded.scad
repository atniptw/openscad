// Locking collar — context assembly diagram
// Left scene:  exploded — parts hovering above the actual water dish
// Right scene: assembled & locked — collar on bottle, base ring around bowl
//
// This file is for visualization only — see 02-locking-collar.scad for the actual parts.

include <../../common/utils.scad>

// ── Same parameters as 02-locking-collar.scad ────────────────────────────────
// Bowl: wide shallow stainless dish, bottle sits inverted in the centre
bowl_od          = 220;   // outer diameter of the wide shallow dish
bowl_h           =  30;   // dish is shallow
bowl_wall        =   2;   // stainless wall thickness
bowl_lip_h       =  10;   // raised inner hub that bottle neck seats into
bowl_lip_od      =  60;   // inner hub diameter (bottle neck rests here)

// Bottle: tall ribbed glass, sits INVERTED — neck down into dish
bottle_od        =  80;   // body diameter
bottle_total_h   = 260;   // overall height
bottle_neck_od   =  44;   // neck diameter (seats into dish hub)
bottle_neck_h    =  50;   // neck length
bottle_shoulder_h=  40;   // shoulder taper height
bottle_body_h    = 170;   // straight body height (= total - neck - shoulder)
bottle_ribcount  =  12;   // number of spiral ribs (visual only)

collar_h         =  30;

wall             =   3;
tab_w            =  12;
tab_h            =  20;
tab_depth        =   6;
lock_angle       =  30;
num_tabs         =   2;

// ── Derived ───────────────────────────────────────────────────────────────────
collar_id = bottle_od + FIT_CLEARANCE * 2;
collar_od = collar_id + wall * 2;

base_id = bowl_od + FIT_CLEARANCE * 2;
base_od = base_id + wall * 2 + tab_depth;

explode_gap      = 50;
scene_spacing    = base_od * 1.5;

// ── Prop modules ─────────────────────────────────────────────────────────────

// Wide shallow stainless dish — flat base, low walls, inner hub for bottle neck
module water_bowl() {
    color("Silver") {
        difference() {
            union() {
                // Main dish cylinder
                cylinder(h = bowl_h, r = bowl_od / 2, $fn = $fn);
                // Inner hub that bottle neck seats into
                cylinder(h = bowl_h + bowl_lip_h, r = bowl_lip_od / 2, $fn = $fn);
            }
            // Hollow out the dish interior (leave floor)
            translate([0, 0, bowl_wall])
                cylinder(h = bowl_h, r = bowl_od / 2 - bowl_wall, $fn = $fn);
            // Hollow out hub centre for the bottle neck
            translate([0, 0, bowl_wall])
                cylinder(h = bowl_h + bowl_lip_h, r = bottle_neck_od / 2 - bowl_wall, $fn = $fn);
        }
    }
}

// Tall ribbed glass bottle — rendered UPRIGHT (neck at top) then flipped in the scene
// so the neck points down into the dish hub.
module water_bottle() {
    color([0.7, 0.92, 0.95, 0.45]) {
        difference() {
            union() {
                // Straight body
                cylinder(h = bottle_body_h, r = bottle_od / 2, $fn = $fn);
                // Shoulder taper (body → neck)
                translate([0, 0, bottle_body_h])
                    cylinder(h = bottle_shoulder_h,
                             r1 = bottle_od / 2, r2 = bottle_neck_od / 2, $fn = $fn);
                // Neck
                translate([0, 0, bottle_body_h + bottle_shoulder_h])
                    cylinder(h = bottle_neck_h, r = bottle_neck_od / 2, $fn = $fn);
            }
            // Hollow interior
            translate([0, 0, 2])
                cylinder(h = bottle_total_h, r = bottle_od / 2 - 3, $fn = $fn);
        }
        // Decorative spiral ribs on the body
        for (i = [0 : bottle_ribcount - 1]) {
            rotate([0, 0, i * (360 / bottle_ribcount) + i * 15])
                translate([bottle_od / 2 - 1, 0, 0])
                    cylinder(h = bottle_body_h * 0.85, r = 2, $fn = 8);
        }
    }
}

// Bottle placed inverted — neck down, dropping into bowl hub
// origin = floor of dish
module bottle_in_bowl(z_lift = 0) {
    // Flip upside-down: rotate 180° around X, then shift up so neck tip is at dish floor level
    translate([0, 0, bowl_h + bowl_lip_h + bottle_neck_h + bottle_shoulder_h + bottle_body_h + z_lift])
        rotate([180, 0, 0])
            water_bottle();
}

// ── Printed part modules ──────────────────────────────────────────────────────

module base_ring() {
    difference() {
        cylinder(h = bowl_h, r = base_od / 2, $fn = $fn);
        translate([0, 0, -1])
            cylinder(h = bowl_h + 2, r = base_id / 2, $fn = $fn);
        for (i = [0 : num_tabs - 1]) {
            rotate([0, 0, i * (360 / num_tabs)]) {
                translate([base_id / 2 + tab_depth / 2, -tab_w / 2, bowl_h - tab_h - 1])
                    cube([tab_depth + 2, tab_w, tab_h + 2]);
                rotate([0, 0, lock_angle / 2])
                    translate([base_id / 2 + tab_depth / 2, -tab_w / 2, bowl_h - tab_h - 1])
                        cube([tab_depth + 2, tab_w, wall * 2]);
            }
        }
    }
}

module bottle_collar(rot = 0) {
    rotate([0, 0, rot])
    union() {
        difference() {
            cylinder(h = collar_h, r = collar_od / 2, $fn = $fn);
            translate([0, 0, -1])
                cylinder(h = collar_h + 2, r = collar_id / 2, $fn = $fn);
        }
        for (i = [0 : num_tabs - 1]) {
            rotate([0, 0, i * (360 / num_tabs)])
                translate([collar_id / 2 + FIT_CLEARANCE, -tab_w / 2, -tab_h])
                    cube([tab_depth, tab_w, tab_h]);
        }
    }
}

// ── LEFT SCENE — exploded ─────────────────────────────────────────────────────

// Water dish
water_bowl();

// Base ring around the dish, cross-sectioned to reveal tab slots
color("MediumAquamarine")
difference() {
    base_ring();
    translate([-base_od, -base_od, -1])
        cube([base_od, base_od * 2, bowl_h + 2]);
}

// Bottle collar hovering above the dish, tabs aligned with slots (unlocked)
// Collar wraps the bottle body just above the shoulder
collar_assembled_z = bowl_h + bowl_lip_h + bottle_neck_h + bottle_shoulder_h;
translate([0, 0, collar_assembled_z + explode_gap])
    color("SteelBlue", 0.9)
        bottle_collar(rot = 0);

// Bottle hovering further above the collar
bottle_in_bowl(z_lift = explode_gap + collar_h + 20);

// Drop-path arrows
for (i = [0 : num_tabs - 1]) {
    rotate([0, 0, i * (360 / num_tabs)])
        translate([base_id / 2 + tab_depth / 2 + 1, 0, bowl_h + 5])
            color("Orange")
                cylinder(h = explode_gap - 8, r = 1.2, $fn = 8);
}

// ── RIGHT SCENE — assembled & locked ─────────────────────────────────────────

translate([scene_spacing, 0, 0]) {
    // Water dish
    water_bowl();

    // Base ring around the dish (full, no cross-section)
    color("MediumAquamarine")
        base_ring();

    // Bottle sitting inverted in dish
    bottle_in_bowl();

    // Collar locked on bottle body, tabs seated in base ring pockets
    translate([0, 0, collar_assembled_z - tab_h])
        color("Coral", 0.9)
            bottle_collar(rot = lock_angle);
}
