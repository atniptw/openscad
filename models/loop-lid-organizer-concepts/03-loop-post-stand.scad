// Concept 3: countertop or shelf stand with upward loop posts.
// Each lid hangs by the rear loop on a peg and rests on the tray floor.
//
// Usage:
//   openscad -o 03-loop-post-stand.stl 03-loop-post-stand.scad

include <../../common/utils.scad>

lid_d = 78;
loop_t = 7;

n_lids = 4;
station_gap = 8;
side_margin = 10;
base_t = 4;
base_depth = 64;
front_lip_h = 10;
rear_wall_t = 4;
rear_wall_h = 42;

peg_d = loop_t + 4;
peg_h = 42;
peg_tilt = 12;
peg_y = 40;
peg_cap_d = peg_d + 4;
gusset_w = 16;
gusset_d = 12;
gusset_h = 18;

station_w = lid_d + station_gap;
total_w = 2 * side_margin + n_lids * station_w;

module peg_station(station_x) {
    translate([station_x - gusset_w / 2, peg_y - gusset_d / 2, base_t])
        cube([gusset_w, gusset_d, gusset_h]);

    translate([station_x, peg_y, base_t])
        rotate([0, -peg_tilt, 0])
            union() {
                cylinder(h = peg_h, d1 = peg_d + 2, d2 = peg_d);
                translate([0, 0, peg_h])
                    sphere(d = peg_cap_d);
            }
}

union() {
    cube([total_w, base_depth, base_t]);

    translate([0, 0, base_t])
        cube([total_w, 4, front_lip_h]);

    translate([0, base_depth - rear_wall_t, base_t])
        cube([total_w, rear_wall_t, rear_wall_h]);

    for (index = [0 : n_lids - 1]) {
        station_x = side_margin + station_w / 2 + index * station_w;
        peg_station(station_x);
    }
}
