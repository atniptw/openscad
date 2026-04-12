// Yeti-style water bottle lid rack — kitchen cabinet organiser
// Holds wide-mouth lids (Yeti / Hydro Flask style) standing on edge,
// dish-rack style.  Slots are open front AND back; a cylindrical cradle
// groove at the base of each slot keeps the round lid rim from rolling.
//
// Usage:
//   openscad -o yeti-style-lid-rack.stl yeti-style-lid-rack.scad
//   openscad -D "n_lids=4" -o yeti-style-lid-rack-4.stl yeti-style-lid-rack.scad

include <../../common/utils.scad>

// ── Parameters ────────────────────────────────────────────────────────────────

lid_od        = 100;  // lid outer diameter (mm)
slot_gap      = 25;   // clear gap between dividers for each lid (mm)
n_lids        =  6;   // number of lid slots
slot_h        = 50;   // slot wall height above the base (lids protrude above) (mm)
wall          =  4;   // outer side-wall thickness (mm)
divider_t     =  3;   // divider fin thickness (mm)
base_h        = 12;   // floor thickness; must exceed cradle_r (mm)
rack_depth    = 40;   // front-to-back depth of the rack (mm)
cradle_r      = 28;   // large radius gives a visible curved profile at front/back faces (mm)
cradle_depth  = 10;   // groove depth below the slot floor (mm)

// ── Derived ───────────────────────────────────────────────────────────────────

slot_w  = slot_gap;
total_w = 2 * wall + n_lids * slot_w + (n_lids - 1) * divider_t;
total_d = rack_depth;
total_h = base_h + slot_h;
cradle_z = base_h + cradle_r - cradle_depth;

// ── Model ─────────────────────────────────────────────────────────────────────

difference() {
    // Solid block
    cube([total_w, total_d, total_h]);

    for (i = [0 : n_lids - 1]) {
        slot_x = wall + i * (slot_w + divider_t);

        // Open vertical slot — open on both front and back faces
        translate([slot_x, -1, base_h])
            cube([slot_w, total_d + 2, slot_h + 1]);

        // Cradle groove: cylindrical scoop at the floor of each slot.
        // Axis runs along X (slot-width direction); the arc in the Y-Z plane
        // cradles the circular lid rim and prevents it from rolling.
        translate([slot_x, total_d / 2, cradle_z])
            rotate([0, 90, 0])
                cylinder(h = slot_w, r = cradle_r);
    }
}
