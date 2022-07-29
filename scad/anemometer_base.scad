include <../../libraries/NopSCADlib/lib.scad>

use <../../libraries/Round-Anything/polyround.scad>

//! Assembly instructions
module main_assembly()
assembly("main"){
    housing_stl();
    translate([0,0,70]) spinner_assembly();
    plate_assembly();
}

module spinner_assembly()
stl("spinner"){
    
    rotate([90,0,0]) import("../Anemometer_Oberteil.stl");
    translate([0,0,3]) ball_bearing(BB608);
}

module enc_hull(){
    hull(){
        translate([0,0,69]) cylinder(h=1, d=60);
        cube([80,120,.1], center=true);
    }
}

module vents(n=5, h=20, w=40){
    vh=h;
    vw=w/n/2;
    r=vw/2;
    linear_extrude(20, center=true, convexity=n) translate([-h/2,(-w/2)+vw/2,0]) for (p=[1:n]){
        translate([0,(p-1)*(w/n),0]) polygon(polyRound([
                [0,0,r],
                [vh,0,r],
                [vh,vw,r],
                [0,vw,r]
            ], fn=30));
    }
}

//!vents();

module housing_stl()
stl("housing"){
    union(){
        difference(){
            enc_hull();
            #translate([0,0,-20]) cylinder(h=200, d=8.2, $fn=200, center=true);
            difference(){
                translate([0,0,-2]) scale([.98,.998,1]) enc_hull();
                translate([0,0,0]) cylinder(h=70, d=8.2+2, $fn=100);
                translate([-40,0,10]) cube([80,2,62]);
            }
        }
    }
}

module plate_stl()
stl("plate"){
    difference(){
        union(){
            cube([80,120,2], center=true);
            translate([0,40,0]) pcb_base(RPI0, height=4, thickness=2, wall=2);
        }
        cylinder(h=20,d=8.2,center=true, $fn=200);
        translate([-20,0,0]) vents(6, 20, 20);
        translate([20,0,0]) vents(6, 20, 20);
    }
}

//! Insert the heat-set inserts
//
module plate_assembly()
assembly("plate"){
    plate_stl();
    translate([0,40,4]) rotate([0,0,180]) pcb_assembly(RPI0);
}

//!plate_assembly();
//!housing_stl();

if($preview) main_assembly();