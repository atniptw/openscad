// Concept 2C: higher-capacity leaning cradle tray.
// Adds a fifth slot with tighter spacing and slimmer dividers.
//
// Usage:
//   openscad -o 02c-leaning-cradle-tray-capacity.stl 02c-leaning-cradle-tray-capacity.scad

include <../../common/utils.scad>

lid_d = 78;
lid_h = 44;

n_lids = 5;
slot_gap = 20;
divider_t = 2.6;
side_wall = 3.6;
base_t = 4;
tray_depth = 74;
rear_band = 18;
rear_rise = 16;
rear_wall_h = 24;
front_lip_h = 10;
divider_h = 28;
cradle_r = 17;
cradle_z = 21;
cradle_y = 19;

total_w = 2 * side_wall + n_lids * slot_gap + (n_lids - 1) * divider_t;

module tray_shell() {
    union() {
        hull() {
            cube([total_w, tray_depth, base_t]);
            translate([0, tray_depth - rear_band, rear_rise])
                cube([total_w, rear_band, base_t]);
        }

        cube([total_w, 4, front_lip_h]);

        translate([0, tray_depth - 4, rear_rise])
            cube([total_w, 4, rear_wall_h]);
    }
}

difference() {
    union() {
        tray_shell();

        for (divider_index = [1 : n_lids - 1]) {
            divider_x = side_wall + divider_index * slot_gap + (divider_index - 1) * divider_t;
            translate([divider_x, 8, base_t])
                cube([divider_t, tray_depth - 20, divider_h]);
        }

        translate([0, 0, base_t])
            cube([side_wall, tray_depth, rear_rise + rear_wall_h]);

        translate([total_w - side_wall, 0, base_t])
            cube([side_wall, tray_depth, rear_rise + rear_wall_h]);
    }

    for (slot_index = [0 : n_lids - 1]) {
        slot_x = side_wall + slot_index * (slot_gap + divider_t);
        translate([slot_x - 1, cradle_y, cradle_z])
            rotate([0, 90, 0])
                cylinder(h = slot_gap + 2, r = cradle_r);
    }
}
