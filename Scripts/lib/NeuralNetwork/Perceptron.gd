extends Node
var RANDOM = RandomNumberGenerator.new()
var Name
var Type
var Bias
var Output
var Order
func _init(name,type):
    RANDOM.randomize()
    Name=name
    Type=type
    Bias=RANDOM.randf_range(-1,1)
    Output=0
    Order=0
    
