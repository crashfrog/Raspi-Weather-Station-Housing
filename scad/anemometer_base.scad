//! An anaerometer and atmospheric sampling station based on RasPi Zero W.

include <NopSCADlib/lib.scad>

use <Round-Anything/polyround.scad>

$explode=1;

tallness = 70;
base_width = 155;
base_height = 115;

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
    translate([5,-45,0]) children();
}

module position_jack(){
    translate([-40,-45,0]) rotate([0,0,90]) children();
}

module position_lugs(z=0){
    for (coord=housing_plate_lugs){
        translate([coord[0], coord[1], z]) children();
    }
}

module position_retaining_screw(z=tallness-10){
    translate([5,0,z]) rotate([0,-90,0]) children();
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
    //translate([0,0,-20]) color("gray") cylinder(h=200, d=8, $fn=200, center=true);
    translate([0,0,-20]) rod(8,200,center=true);
    explode(-60) position_lugs(0) rotate([0,180,0]) screw(M2p5_cap_screw, 7);
    position_retaining_screw() explode(50, explode_children=true) translate([0,0,23]) screw(M2p5_cap_screw, 15);
    housing_assembly();
}

//! Press-fit the skate bearing into the anemometer spinner.
//! Epoxy or glue the magnet into the magnet void.
module spinner_assembly()
assembly("spinner"){
    explode(10) rotate([90,0,0]) color("teal") import("../Anemometer_Oberteil.stl");
    explode(-20) translate([0,0,3]) ball_bearing(BB608);
    explode(-40) translate([22.5,0,0]) magnet(MAGRE6x2p5);
}   



module enc_hull(w=base_width, h=base_height, z=tallness-1){
    hull(){
        translate([0,0,z]) cylinder(h=1, d=60);
        cube([h,w,.1], center=true);
        position_for_raspi() pi_assembly();
        //position_for_bme680() pcb(BME680);
        position_for_PMSA003I() pcb(PMSA003I);
        //position_jack() translate([0,0,-9]) rotate([0,0,0]) pcb(USB_PANEL);
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
                [vh,0,r],
                [vh,vw,r],
                [0,vw,r]
            ], fn=30));
    }
}



housing_plate_lugs = [[base_height/2-5, base_width/2-5],
                      [-base_height/2+5, base_width/2-5],
                      [base_height/2-5, -base_width/2+5],
                      [-base_height/2+5, -base_width/2+5],
                     ];




module housing_stl()
color("teal", alpha=($explode==0) ? 0.05 : 1.0) stl("housing"){
     union(){
        difference(){
            minkowski(convexity=6) {
                enc_hull(); 
                sphere(.6);
            }
            position_retaining_screw() translate([0,0,12]) insert_hole(F1BM2p5, counterbore = 5, horizontal = false);
            position_retaining_screw() translate([0,0,22.8]) cylinder(h=base_height/2, d=8);
            translate([0,0,-20]) cylinder(h=200, d=8.2, $fn=200, center=true);
            difference(){
                translate([0,0,-1]) scale([.985,1.0,1.01]) enc_hull();
                translate([0,0,0]) cylinder(h=70, d=8.2+2, $fn=100);
                translate([-40,0,40]) cube([80,2,62]);
                position_lugs(30) rotate([0,180,0]) insert_boss(F1BM2p5, z=30, wall=3);
                position_retaining_screw() translate([0,0,0]) cylinder(h=base_height/2, d=10);
                //mounting post for hall effect sensor
                translate([0,22.5,tallness]) cube([10,3,10], center=true);
            }
        }
    }
}

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
            position_lugs(2) rotate([0,180,0]) color("red") insert_boss(F1BM2, z=2, wall=3);
            position_jack() pcb_screw_positions(USB_PANEL) insert_boss(F1BM2p5, z=s);
        }
        cylinder(h=20,d=8.2,center=true, $fn=200);
        translate([-15,2,0]) vents(11, 15, 32);
        translate([20,0,0]) vents(12, 20, 50);
        position_for_raspi() pcb_screw_positions(RPI0) insert_hole(F1BM2p5);
        position_for_bme680() pcb_screw_positions(BME680) insert_hole(F1BM2p5);
        position_for_PMSA003I() pcb_screw_positions(PMSA003I) insert_hole(F1BM2p5);
        
        position_lugs(-2.5) rotate([0,180,0]) screw_polysink(M3_cs_cap_screw, h=10);
        
        //port for USB plug
        
        position_jack() translate([0,0,-9.2]) rotate([0,0,0]) pcb(USB_PANEL);
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
    #translate([-55,-36,0]) cube([85, 20, 12]);
}

//!pi_assembly();

//!plate_stl();

//! Insert the heat-set inserts.
//! Mount the components.
//! Mount the panel-mount USB connector, and connect to the RPi0.
//! Connect the components using STEMMA-QT cables.
module plate_assembly()
assembly("plate"){
    color("teal") plate_stl();
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
    
}



//!spinner_assembly();
//!plate_assembly();
//!housing_assembly();

if($preview) main_assembly();