extends Node
class_name Orientation
var f0 : float;
var f1 : float;
var f2 : float;
var f3 : float;

var b0 : float;
var b1 : float;
var b2 : float;
var b3 : float;

var start_angle: float; # Multiples of 60°

enum Types {
	POINTY,
	FLAT
}

func _init(f0_:float, f1_:float, f2_:float, f3_:float, b0_:float, b1_:float, b2_:float, b3_:float, start_angle_:float):
	f0 =f0_;
	f1 = f1_;
	f2 = f2_;
	f3 = f3_;
	b0 = b0_;
	b1 = b1_;
	b2 = b2_;
	b3 = b3_;
	start_angle = start_angle_;

