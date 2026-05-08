// Dog ramp side railing — modular fence segments
// The C-clamp slides onto the ramp's side board horizontally from the
// outside — no vertical clearance needed. Two arms grip the board above
// and below; the slot opens outward (Y=0 face). Place segments end-to-end
// along each long edge; adjacent segments interlock via a flat tab-and-socket.
//
// BEFORE PRINTING: measure the side-board thickness and update board_t,
// or override on the command line:
//   openscad -D "board_t=18" -o ramp-railing.stl ramp-railing.scad
//
// Print orientation: flat on bed (Z-up), no supports required.
//
// Render:
//   openscad -o ramp-railing.stl ramp-railing.scad

include <../../common/utils.scad>

// ── Parameters ────────────────────────────────────────────────────────────────

board_t    = 15;   // ramp side-board thickness — MEASURE AND UPDATE (mm)
board_grip = 20;   // height of board section gripped by the two arms (mm)
segment_l  = 150;  // length of one printed segment (mm)
post_h     = 65;   // post height above the ramp surface (mm)
post_sq    = 10;   // post cross-section side (mm)
rail_h     =  8;   // top-rail height (mm)
rail_d     =  8;   // top-rail depth (mm)
wall       =  5;   // arm and back-wall thickness (mm)
tab_l      = 12;   // segment connector tab protrusion length (mm)
tab_h      =  3;   // segment connector tab thickness (mm)

// ── Derived ───────────────────────────────────────────────────────────────────

slot_depth = board_t + FIT_CLEARANCE;   // slot depth in Y (board slides in)
outer_y    = slot_depth + wall;         // total clamp depth: open slot + back wall
clamp_h    = 2 * wall + board_grip;     // total height: bottom arm + slot + top arm
z_surf     = clamp_h;                   // Z level of the ramp surface

post_xa = segment_l * 0.2;
post_xb = segment_l * 0.8;

// ── Modules ───────────────────────────────────────────────────────────────────

// C-clamp body. Slot opens at Y=0 (outer face, facing the installer).
// Back wall at Y=slot_depth..outer_y presses against the board's inner face.
// Upper arm bridges across the slot at Z=wall+board_grip — no supports needed.
module clamp_body() {
    difference() {
        cube([segment_l, outer_y, clamp_h]);
        translate([0, 0, wall])
            cube([segment_l, slot_depth, board_grip]);
    }
}

module post(x_pos) {
    translate([x_pos - post_sq / 2, (outer_y - post_sq) / 2, z_surf])
        cube([post_sq, post_sq, post_h]);
}

module top_rail() {
    translate([0, (outer_y - rail_d) / 2, z_surf + post_h - rail_h])
        cube([segment_l, rail_d, rail_h]);
}

// Male tab protrudes from +X end face, in the solid upper-arm zone.
module tab_male() {
    translate([segment_l, (outer_y - rail_d) / 2, clamp_h - wall])
        cube([tab_l, rail_d, tab_h]);
}

// Female socket cut into -X end face; receives male tab of adjacent segment.
module tab_female() {
    translate([0,
               (outer_y - rail_d) / 2 - FIT_CLEARANCE / 2,
               clamp_h - wall - FIT_CLEARANCE / 2])
        cube([tab_l, rail_d + FIT_CLEARANCE, tab_h + FIT_CLEARANCE]);
}

// ── Main ──────────────────────────────────────────────────────────────────────

difference() {
    union() {
        clamp_body();
        post(post_xa);
        post(post_xb);
        top_rail();
        tab_male();
    }
    tab_female();
}
