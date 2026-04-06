// Simple cable clip / cord organizer
// Clips onto a desk edge or surface.
//
// Render: openscad -o cable-clip.stl cable-clip.scad

include <../../common/utils.scad>

// ── Parameters ────────────────────────────────────────────────────────────────
cable_diameter = 5;    // mm – diameter of the cable to hold
wall           = 2;    // mm – wall thickness
length         = 20;   // mm – depth of the clip
desk_thickness = 20;   // mm – thickness of the surface it clips to

// ── Computed ──────────────────────────────────────────────────────────────────
outer_r = cable_diameter / 2 + wall;
inner_r = cable_diameter / 2 + FIT_CLEARANCE;
gap     = cable_diameter * 0.6;  // opening wide enough to snap a cable in

// ── Model ─────────────────────────────────────────────────────────────────────
module cable_clip() {
    difference() {
        union() {
            // Clip body (C-shape cross-section extruded along length)
            linear_extrude(length)
                difference() {
                    circle(r = outer_r);
                    circle(r = inner_r);
                    // Cut gap for snapping cable in
                    translate([0, inner_r])
                        square([gap, outer_r * 2], center = true);
                }

            // Mounting tab that hooks under desk edge
            translate([-outer_r, -outer_r, 0])
                cube([outer_r * 2, wall, length]);
            translate([-outer_r, -outer_r - desk_thickness, 0])
                cube([outer_r * 2, desk_thickness + wall, wall]);
        }
    }
}

cable_clip();
