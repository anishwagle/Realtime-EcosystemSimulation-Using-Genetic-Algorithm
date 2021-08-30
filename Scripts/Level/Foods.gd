extends Spatial
var food = preload("res://Assets/Level/Env/Food.tscn")
var location = Vector3()
var size = 14
var number = rand_range(0,15)
var timer
func _ready():
	timer = get_tree().create_timer(0.0)
func _process(delta):
	randomize()
	Instance()
func Instance():
	
	if timer.time_left <= 0.0:
		number = rand_range(0,20)
		for i in range(number):
			location.x = rand_range(-size,size)
			location.y = 1
			location.z = rand_range(-size,size)
			var fo = food.instance()
			fo.transform.origin = location
			add_child(fo)
		timer = get_tree().create_timer(rand_range(7,20))
		
		
