//! An anaerometer and atmospheric sampling station based on RasPi Zero W.

include <NopSCADlib/lib.scad>

use <Round-Anything/polyround.scad>

$explode=1;
$fn=40;

tallness = 70;
base_width = 155;
base_height = 115;
magnet = ["MAG5x1", "Magnet", 5, 0, 1, .25];
bearing = BB608;

module position(w, h){
    for (p=[-1,1], q=[-1,1]){
        translate([q*h/2, p*w/2, 0]) children();
    }
}

module position_for_raspi(){
    translate([0,40,0]) rotate([0,0,180]) children();
}

module position_for_bme680(w=20, h=11){
    translate([-15,-15,0]) rotate([0,0,90]) children();
}

module position_for_PMSA003I(w=30, h=45){
    translate([5,-48,0]) children();
}

module position_jack(){
    translate([-40,-45,0]) rotate([0,0,90]) children();
}

module position_lugs(z=0){
    for (coord=housing_plate_lugs){
        translate([coord[0], coord[1], z-.02]) rotate([0,0,coord[2]]) children();
    }
}

module position_retaining_screw(z=tallness-10){
    translate([-3,0,z]) rotate([0,-90,0]) children();
}

s=4.8; //standoff height




BME680 = ["BME680", "BME680 Atmospheric Sensor STEMMA-QT",
    18, 26, 1.4, 3, 2.65, 6, "black", false, [//holes
                                             [3, 3],
                                             [18-3,3],
                                             [3,26-3],
                                             [18-3,26-3],], 
                                             [//components
                                               [9,13,0,"chip",4,4,1,"silver"],
                                               [9,2,0,"chip",6,4,3,grey(15)],
                                               [9,24,0,"chip",6,4,3,grey(15)],
                                             ], 
                                             []
];

PMSA003I = ["PMSA003I", "PMSA003I Air Particulate Sensor STEMMA-QT",
    50,35,1.4,3,2.65,4,grey(15), false, [[3,2.5],
                                        //[50-3,3],
                                        [3,35-2.5],
                                        [50-3,35-3]],
                                        [//components
                                            [31,17.5,0,"chip",38,35,11.9,"blue"],
                                            [40,25,0,"chip",20.1,20.1,12.1,"black"],
                                            [8.5,2,0,"chip",6,4,3,grey(15)],
                                            [8.5,33,0,"chip",6,4,3,grey(15)],
                                        ],
                                        [],
];

QWIIC_HAT = ["QWIIC_HAT", "SparkFun Qwiic HAT",
    22, 52, 1.4, 1.5, 2.65, 4, "red", false, [],
    [//components
        [18.5,26,90,"2p54socket", 20, 2, false, 5, true],
        [2.5,40,90,"chip",6,4,3,grey(15)],
        [2.5,31,90,"chip",6,4,3,grey(15)],
        [2.5,21,90,"chip",6,4,3,grey(15)],
        [2.5,12,90,"chip",6,4,3,grey(15)],
    ],
    [],
];

//!pcb(QWIIC_HAT);

USB_PANEL = ["musb_jack", "Micro USB Panel Jack", 
     36, 10, 8,4.9,3,2,grey(15), false, 
     [//holes
        [4,5],
        [27+5.2,5],
     ],
     [//components
        [18,6,[0,-90,90],"usb_uA",true,"red"],
        [18,5,0,"chip",20.2,10.2,12,"black"],
     ],[]
];

//!pcb(USB_PANEL);

//!pcb(PMSA003I);

//! Assembly instructions
//! Mount the anemometer spinner on top of the mounting rod.
//! Slide the housing up the rod and mount with an M2.5x15 screw.
//! Connect the hall effect sensor to the RasPI.
//! Mate the PCB base to the housing using M2.5x5 screws.
module main_assembly()
assembly("main"){
    explode(30, explode_children=true) translate([0,0,tallness])  spinner_assembly();
    explode(-40, explode_children=true) plate_assembly();
    translate([0,0,-20]) rod(8,200,center=true);
    explode(-60) position_lugs(0) rotate([0,180,0]) screw(M2p5_cap_screw, 7);
    position_retaining_screw() explode(50, explode_children=true) translate([0,0,23]) screw(M2p5_cap_screw, 15);
    housing_assembly();
}

module spinner_cup(r=30, t=1, r2=80, top=true){
    translate([0,0,r]) 
        difference(){
            intersection(){
                union(){
                    sphere(r=r);
                    t=1.2;
                    translate([1.5,r2/2,-r+(t/2)]) cube([3, r2, t], center=true);
                    if (top){
                        translate([1.5,r2/2,r-(t/2)]) cube([3, r2, t], center=true);
                    }
                }

            translate([r/2,0,0]) cube([r, r2*2, r*2], center=true);
        }
        
        sphere(r=r-t);
    }
}


//!spinner_cup();

module spinner_stl(c=3, cr=25, r=75)
color("teal") stl("spinner"){
    difference(){
        union(){
            for (p=[1:c]){
                rotate([0,0,p*(360/c)]) translate([0,0,0]) union(){
                    translate([0,-r,0]) spinner_cup(r=cr, r2=r);
                }
            }
            hull() {
                cylinder(h=1, d=60);
                translate([0,0,cr*2-1]) cylinder(h=1, d=cr, $fn=16);
            }
        }
        translate([0,0,-.01]) cylinder(h=bb_width(bearing)+0.2, d=bb_diameter(bearing)+0.2, $fn=12);
        translate([22.5,0,-.01]) cylinder(h=magnet_h(magnet)+0.2, d=magnet_od(magnet)+0.2, $fn=12);
    }
}

//!spinner_stl();


//! Press-fit the skate bearing into the anemometer spinner.
//! Epoxy or glue the magnet into the magnet void.
module spinner_assembly()
assembly("spinner"){
    explode(-20) translate([0,0,bb_width(bearing)/2]) ball_bearing(bearing);
    explode(-40) translate([22.5,0,0]) magnet(magnet);
    explode(10) rotate([0,0,0]) color("teal") spinner_stl();
}

//!spinner_assembly();



module enc_hull(w=base_width, h=base_height, z=tallness-1){
    hull(){
        translate([0,0,z]) cylinder(h=1, d=60, $fn=20);
        translate([0,0,10]) cube([h,w,20], center=true);
        //position_for_raspi() pi_assembly();
        //position_for_PMSA003I() pcb(PMSA003I);
    }
}

//!enc_hull();

module vents(n=5, h=20, w=40){
    vh=h;
    vw=w/n/2;
    r=vw/2;
    linear_extrude(20, center=true, convexity=n) translate([-h/2,(-w/2)+vw/2,0]) for (p=[1:n]){
        translate([0,(p-1)*(w/n),0]) polygon(polyRound([
                [0,0,r],
                [0,vw,r],
                [vh,vw,r],
                [vh,0,r],
            ], fn=3));
    }
}

//!vents();

w=5;

housing_plate_lugs = [[base_height/2-w, base_width/2-w, -90],
                      [-base_height/2+w, base_width/2-w, -90],
                      [base_height/2-w, -base_width/2+w, 90],
                      [-base_height/2+w, -base_width/2+w, 90],
                     ];




module housing_stl()
stl("housing"){
     color("teal", alpha=($explode==0) ? 0.05 : 1.0) difference(){
        enc_hull();
        position_retaining_screw() translate([0,0,12]) insert_hole(F1BM2p5, counterbore = 10, horizontal = true);
        position_retaining_screw() translate([0,0,22.8]) cylinder(h=base_height/2, d=8, $fn=12);
        translate([0,0,-20]) cylinder(h=200, d=8.2, $fn=12, center=true);
        difference(){
            translate([0,0,-1]) scale([.985,.989,1.005]) enc_hull();
            translate([0,0,30]) cylinder(h=70, d=8.2+2, $fn=12);
            translate([-base_width/2,0,45]) cube([base_width,2,base_height]);
            position_lugs(0) rotate([0,180,0]) insert_lug(F1BM2p5, wall=2, extension=4);
            position_retaining_screw() translate([0,0,0]) cylinder(h=base_height/2, d=10, $fn=12);
            // //mounting post for hall effect sensor
            translate([0,22.5,tallness]) cube([10,3,10], center=true);
        }
    }
}

//!intersection(){
//    rotate([0,0,0]) housing_stl();
//    translate([-100,0,0]) cube([200, 400, 400], center=true);
//}

//! Heat-set inserts into the four plate mounting lugs and into the rod retaining lug.
module housing_assembly()
assembly("housing"){
    explode(-45) position_lugs(0) rotate([0,180,0]) insert(F1BM2p5);
    position_retaining_screw() explode(50) translate([0,0,23]) insert(F1BM2p5);
    explode(-200) translate([0,22.5,tallness-3]) rotate([90,0,0]) TO220("Hall Effect Sensor");
    
    housing_stl(); //leave this last
}




module plate_stl(w=base_width, h=base_height)
stl("plate"){
    difference(){
        union(){
            cube([h,w,2], center=true);
            position_for_raspi() pcb_screw_positions(RPI0) insert_boss(F1BM2p5, z=s);
            position_for_bme680() pcb_screw_positions(BME680) insert_boss(F1BM2p5, z=s);
            position_for_PMSA003I() pcb_screw_positions(PMSA003I) insert_boss(F1BM2p5, z=s);
            position_lugs(2) rotate([0,180,0]) insert_boss(F1BM2p5, z=2, wall=3);
            position_jack() pcb_screw_positions(USB_PANEL) insert_boss(F1BM2p5, z=s);
        }
        cylinder(h=20,d=8.2,center=true, $fn=10);
        translate([-15,2,0]) vents(12, 13, 32);
        translate([20,-5,0]) vents(12, 20, 50);
        position_for_raspi() pcb_screw_positions(RPI0) insert_hole(F1BM2p5);
        position_for_bme680() pcb_screw_positions(BME680) insert_hole(F1BM2p5);
        position_for_PMSA003I() pcb_screw_positions(PMSA003I) insert_hole(F1BM2p5);
//        
        position_lugs(-2.5) rotate([0,180,0]) screw_polysink(M3_cs_cap_screw, h=10);
//        
//        //port for USB plug
//        
        position_jack() translate([0,0,0]) rotate([0,0,0]) cube([20.2, 10.2, 12.2], center=true);
        position_jack() pcb_screw_positions(USB_PANEL) insert_hole(F1BM2p5);
        
    }
}

module pi_assembly()
assembly("pi"){
    pcb(RPI0);
    explode(10) translate([0,11.5,0]) pin_header(2p54header, 20, 2);
    explode(25) translate([0,19,9]) rotate([180,0,-90]) pcb(QWIIC_HAT);
    explode(30) translate([-10,19,9]) pin_header(2p54header, 2, 1);
    explode(30) translate([20,19,9]) pin_header(2p54header, 2, 1);
    translate([-55,-36,0]) cube([85, 20, 12]);
}

//!pi_assembly();

//!plate_stl();

//! Insert the heat-set inserts.
//! Mount the components.
//! Mount the panel-mount USB connector, and connect to the RPi0.
//! Connect the components using STEMMA-QT cables.
module plate_assembly()
assembly("plate"){
    explode(25) translate([0,0,s]) {
        position_for_raspi() pi_assembly();
        position_for_bme680() rotate([0,180,0]) pcb(BME680);
        position_for_PMSA003I() pcb(PMSA003I);
    }
    explode(-25) position_jack() translate([0,0,-9]) rotate([0,0,0]) pcb(USB_PANEL);
    explode(-35) position_jack() pcb_screw_positions(USB_PANEL) rotate([0,180,0]) translate([0,0,9.2]) screw(M2p5_cap_screw, 15);
    explode(15) translate([0,0,s]) {
        position_for_raspi() pcb_screw_positions(RPI0) insert(F1BM2p5);
        position_for_bme680() pcb_screw_positions(BME680) insert(F1BM2p5);
        position_for_PMSA003I() pcb_screw_positions(PMSA003I) insert(F1BM2p5);
        position_jack() pcb_screw_positions(USB_PANEL) insert(F1BM2p5);
    }
    explode(35) translate([0,0,s]) {
        position_for_raspi() pcb_screw_positions(RPI0) screw(M2p5_cap_screw, 5);
        position_for_bme680() pcb_screw_positions(BME680) screw(M2p5_cap_screw, 5);
        position_for_PMSA003I() pcb_screw_positions(PMSA003I) screw(M2p5_cap_screw, 5);
    }
    color("teal") plate_stl();
}



//!spinner_assembly();
//!plate_assembly();
//!housing_assembly();

//!plate_stl();
//!housing_stl();
//!spinner_stl();

if($preview) main_assembly();