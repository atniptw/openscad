// Concept 1: wall or cabinet-side hook rail for loop-back lids.
// Intended for BlenderBottle-style lids with a rear carry loop.
//
// Usage:
//   openscad -o 01-hook-rail.stl 01-hook-rail.scad

include <../../common/utils.scad>

lid_d = 78;
lid_h = 44;
loop_t = 7;

n_lids = 4;
station_gap = 10;
side_margin = 8;
base_t = 4;
base_depth = 34;
front_lip_h = 10;
backplate_t = 4;
backplate_h = 76;

hook_post_w = 14;
hook_post_d = 10;
hook_post_h = 24;
hook_t = 6;
hook_arm_l = 20;
hook_keeper_drop = 12;
hook_z = 48;

bumper_h = 12;
bumper_d = 10;
bumper_z = 8;

station_w = lid_d + station_gap;
total_w = 2 * side_margin + n_lids * station_w;

module hook_station(station_x) {
    bumper_w = station_w - 16;

    translate([station_x - hook_post_w / 2, backplate_t, hook_z - hook_post_h + hook_t])
        cube([hook_post_w, hook_post_d, hook_post_h]);

    translate([station_x - hook_t / 2, backplate_t + hook_post_d - hook_t, hook_z])
        cube([hook_arm_l, hook_t, hook_t]);

    translate([station_x + hook_arm_l - hook_t, backplate_t + hook_post_d - hook_t, hook_z - hook_keeper_drop])
        cube([hook_t, hook_t, hook_keeper_drop + hook_t]);

    translate([station_x - bumper_w / 2, base_depth - bumper_d, bumper_z])
        cube([bumper_w, bumper_d, bumper_h]);
}

union() {
    cube([total_w, base_depth, base_t]);

    translate([0, 0, base_t])
        cube([total_w, backplate_t, backplate_h]);

    translate([0, base_depth - 4, base_t])
        cube([total_w, 4, front_lip_h]);

    for (index = [0 : n_lids - 1]) {
        station_x = side_margin + station_w / 2 + index * station_w;
        hook_station(station_x);
    }
}
