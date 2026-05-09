// Concept 2: leaning cradle tray with low dividers.
// Lids stand on edge and lean back against a rear support wall.
//
// Usage:
//   openscad -o 02-leaning-cradle-tray.stl 02-leaning-cradle-tray.scad

include <../../common/utils.scad>

lid_d = 78;
lid_h = 44;

n_lids = 4;
slot_gap = 24;
divider_t = 3;
side_wall = 4;
base_t = 4;
tray_depth = 76;
rear_band = 18;
rear_rise = 18;
rear_wall_h = 26;
front_lip_h = 12;
divider_h = 30;
cradle_r = 18;
cradle_z = 22;
cradle_y = 20;

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
