extends Node

signal maxAmountChanged(newMax)
signal CurrentAmountChanged(newCurrent)

export(int) var maxAmount = 100 setget setMax
onready var currentAmount = maxAmount setget setCurrent

func _ready():
	initialize()
	
func setMax(newMax):
	maxAmount = max(1,newMax)
	emit_signal("maxAmountChanged",maxAmount)

func setCurrent(newCurrent):
	currentAmount = clamp(newCurrent,0,maxAmount)
	emit_signal("CurrentAmountChanged",currentAmount)

func initialize():
	emit_signal("maxAmountChanged",maxAmount)
	emit_signal("CurrentAmountChanged",currentAmount)



