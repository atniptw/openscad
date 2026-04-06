// Water bottle lid rack — kitchen cabinet organiser
// Holds wide-mouth lids (Nalgene / Hydro Flask style) standing on edge,
// dish-rack style.  Slots are open front AND back; a cylindrical cradle
// groove at the base of each slot keeps the round lid rim from rolling.
//
// Usage:
//   openscad -o lid-rack.stl lid-rack.scad
//   openscad -D "n_lids=4" -o lid-rack-4.stl lid-rack.scad

include <../../common/utils.scad>

// ── Parameters ────────────────────────────────────────────────────────────────

lid_od        = 63;   // wide-mouth lid outer diameter (mm)
lid_thickness = 18;   // lid body thickness — adjust for your lids (mm)
n_lids        =  6;   // number of lid slots
slot_h        = 40;   // slot wall height above the base (lids protrude above) (mm)
wall          =  4;   // outer side-wall thickness (mm)
divider_t     =  3;   // divider fin thickness (mm)
base_h        = 12;   // floor thickness; must exceed cradle_r (mm)
rack_depth    = 30;   // front-to-back depth of the rack (mm)
cradle_r      =  9;   // cradle groove radius — curves the floor so lids don't roll (mm)

// ── Derived ───────────────────────────────────────────────────────────────────

slot_w  = lid_thickness + FIT_CLEARANCE;
total_w = 2 * wall + n_lids * slot_w + (n_lids - 1) * divider_t;
total_d = rack_depth;
total_h = base_h + slot_h;

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
        translate([slot_x, total_d / 2, base_h])
            rotate([0, 90, 0])
                cylinder(h = slot_w, r = cradle_r);
    }
}
