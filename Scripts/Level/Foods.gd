extends Spatial
var food = preload("res://Assets/Level/Env/Food.tscn")
var location = Vector3()
var size = 14
var healing = 20
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
#			var heal = rand_range(healing/2,healing)
			var heal = healing
			if(rand_range(0,2)>=1):
				heal=-heal
			var fo = food.instance()
			var mat = SpatialMaterial.new()
			if heal<0:
				mat.albedo_color = Color(-heal/20,0,0)
			else:
				mat.albedo_color = Color(0,heal/20,0)
			fo.get_child(1).set_surface_material(0, mat)
			fo.heal = heal
			fo.transform.origin = location
			add_child(fo)
		timer = get_tree().create_timer(rand_range(2,10))
		
		
