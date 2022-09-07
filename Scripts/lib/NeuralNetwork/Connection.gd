extends Node
var RANDOM = RandomNumberGenerator.new();
var Connection;
var Input        
var Out
        
var Weight
var Enable     
var Innov

func _init(input,output,innov):
    RANDOM.randomize()
    Input=input
    Out=output
    Weight=RANDOM.randf_range(-1,1)
    Enable=true
    Innov=innov
    