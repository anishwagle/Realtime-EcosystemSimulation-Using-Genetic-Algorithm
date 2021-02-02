extends Spatial

var player = preload("res://Assets/Level/Player.tscn")
var number = 15
var location = Vector3()
var size = 14
func _ready():
	for i in range(number):
			location.x = rand_range(-size,size)
			location.y = .25
			location.z = rand_range(-size,size)
			var fo = player.instance()
			
			fo.transform.origin = location
			add_child(fo)
	
