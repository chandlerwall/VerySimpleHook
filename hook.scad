include <config.scad>

mount_w = 25;
mount_l = 15;
mount_t = 5;

hole_r = 2;

hook_w = 15;
hook_l = 20;
hook_t = 7;
hook_d = 30; // hook diameter
hook_r = hook_d / 2;
hook_a = 270; // hook angle in degrees

// Choose even numbers: 8 for 3D print optimized and higher e.g. 100 for fine
geometry=4; // Note that module "end" is only accurate for geometry = 4*integer

geo_width=hook_w-hook_t*cos(360/(geometry*2)); // not too sure why this one is here yet

module assembly()
{
    translate([0, hook_t/4, 0])
        hook();

    translate([-hook_l + pad, hook_t/1.1, 0])
    rotate([90, 0, -90])
        mount();
}

module hook()
{
    turn(hook_d, hook_a);
    
    %translate([-hook_r, hook_r, 0])
        end();
    
    translate([-hook_l + pad, 0, 0])
    rotate([0, 0, 0])
        straight(hook_l);
}

module mount()
{
    linear_extrude(height=mount_t)
    difference()
    {
        square([mount_w, mount_l]);
        translate([mount_w * (4/5), mount_l * (1/4)])
            circle(hole_r);
        translate([mount_w * (2/5), mount_l * (1/4)])
            circle(hole_r);
        translate([mount_w * (4/5), mount_l * (3/4)])
            circle(hole_r);
        translate([mount_w * (2/5), mount_l * (3/4)])
            circle(hole_r);
    }
}

module straight(length){
    translate([0,0,hook_t*cos(360/(geometry*2))/2])
        rotate(a=[-180,-90,0])
            linear_extrude(height = length, center = false, convexity = 10, twist = 0)
                hull() {
                    translate([geo_width,0,0])
                    rotate(a=90-(180-(360/geometry))/2)
                        circle(hook_t/2,$fn=geometry);
                    rotate(a=90-(180-(360/geometry))/2)
                        circle(hook_t/2,$fn=geometry);
                }
}

module turn(diameter,angle)
{
    translate([0,diameter/2,0])
        rotate(a=[0,0,-90])
            intersection(){
                ring(diameter=diameter);
                translate([0,0,-(geo_width+hook_t)])
                    pie(radius=diameter/2+hook_t, angle=angle, height=2*(geo_width+hook_t), spin=0);
            }
}

module ring(diameter)
{
    translate([0,0,hook_t*cos(360/(geometry*2))/2])
        rotate_extrude(convexity = 10, $fn = smooth)
            translate([diameter/2, 0, 0])
                rotate(a=[0,0,90])
                    hull() {
                    translate([geo_width,0,0])
                        rotate(a=90-(180-(360/geometry))/2)
                            circle(hook_t/2,$fn=geometry);
                        rotate(a=90-(180-(360/geometry))/2)
                        circle(hook_t/2,$fn=geometry);
                }
}

module end()
{
    linear_extrude(height=hook_w)
    rotate(hook_a)
    intersection()
    {
        translate([hook_t/2, 0, 0])
            square(hook_t, center=true);
        rotate(a=90-(180-(360/geometry))/2)
        circle(hook_t/2, $fn=geometry);
    }
    
}

// ****************************************************************************
// Borrowed code
// ****************************************************************************

/**
 * pie.scad
 *
 * Use this module to generate a pie- or pizza- slice shape, which is particularly useful
 * in combination with `difference()` and `intersection()` to render shapes that extend a
 * certain number of degrees around or within a circle.
 *
 * This openSCAD library is part of the [dotscad](https://github.com/dotscad/dotscad)
 * project.
 *
 * @copyright  Chris Petersen, 2013
 * @license    http://creativecommons.org/licenses/LGPL/2.1/
 * @license    http://creativecommons.org/licenses/by-sa/3.0/
 *
 * @see        http://www.thingiverse.com/thing:109467
 * @source     https://github.com/dotscad/dotscad/blob/master/pie.scad
 *
 * @param float radius Radius of the pie
 * @param float angle  Angle (size) of the pie to slice
 * @param float height Height (thickness) of the pie
 * @param float spin   Angle to spin the slice on the Z axis
 */
module pie(radius, angle, height, spin=0)
{
    // Negative angles shift direction of rotation
    clockwise = (angle < 0) ? true : false;
    // Support angles < 0 and > 360
    normalized_angle = abs((angle % 360 != 0) ? angle % 360 : angle % 360 + 360);
    // Select rotation direction
    rotation = clockwise ? [0, 180 - normalized_angle] : [180, normalized_angle];
    // Render
    if (angle != 0) {
        rotate([0,0,spin]) linear_extrude(height=height)
            difference() {
                circle(radius);
                if (normalized_angle < 180) {
                    union() for(a = rotation)
                        rotate(a) translate([-radius, 0, 0]) square(radius * 2);
                }
                else if (normalized_angle != 360) {
                    intersection_for(a = rotation)
                        rotate(a) translate([-radius, 0, 0]) square(radius * 2);
                }
            }
    }

}