extends Node
class_name FractionalHex

var q:float:
	get:
		return q;
var r:float:
	get:
		return r;
var s:float:
	get:
		return s;

func _init(_q,_r,_s):
	q = _q;
	r = _r;
	s = _s;

func _to_string():
#	return ('q:'+str(q) + ' ' + 'r:'+str(r) + ' ' + 's:'+str(s) + ' ');
	return (str(q) + ' ' +str(r) + ' ' + str(s) + ' ');

