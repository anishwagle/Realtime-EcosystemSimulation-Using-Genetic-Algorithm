extends KinematicBody
signal newGeneration(oldGen)
signal newTraits(traits)

onready var healthBar = $HealthBar3D/Viewport/HealthBar
onready var Gen = $HealthBar3D/Viewport/HealthBar/Generation/GenNumber
onready var Traits = $HealthBar3D/Viewport/HealthBar/Speed/SpeedNumber
onready var health = $Health
onready var eyes = $Eyes/RayCast
onready var vision = $Vision/CollisionShape

onready var player = load("res://Assets/Level/Player.tscn")

var traits = {
	"speed":rand_range(50,100),
	"vision_position":rand_range(-1,1),
	"vision_size":5,
	"size":rand_range(0.4,0.6)
}

var gen=0
var food_counter = 0
var trackTimer = 0
var size = 14
var rotationSpeed = 100
var is_walking = false
var is_rotating = false
var gravity = 12
var vector_gravity=Vector3()
var random = RandomNumberGenerator.new()
var rotationTime
var globalDelta = 0
var looking_at = false

func _ready():
	eyes.cast_to = Vector3(0,0,-traits.vision_size + traits.vision_position )
	scale = Vector3(traits.size,traits.size,traits.size)
	vision.transform.origin.z = traits.vision_position
	vision.shape.radius = (traits.vision_size)
	
	health.connect("CurrentAmountChanged",healthBar,"set_value")
	health.connect("maxAmountChanged",healthBar,"set_max")
	
	connect("newGeneration",Gen,"UpdateGen")
	connect("newTraits",Traits,"UpdateTraits")
	
	emit_signal("newGeneration",gen)
	emit_signal("newTraits",traits)
	
	health.initialize()
	rotationTime = get_tree().create_timer(0.0)
	pass

func _process(delta):
	globalDelta = delta
	random.randomize()
	if not is_on_floor():
		vector_gravity.y-=gravity*delta
	move_and_slide(vector_gravity,Vector3.UP)
	
	LifeCycle(delta)
	Mutation()
	Wandering()
	if(!is_rotating):
		if(eyes.is_colliding()):
			var item = eyes.get_collider()
			if(item != null):
				if(item.is_in_group("Food")):
					look_at(Vector3(item.global_transform.origin.x,global_transform.origin.y,item.global_transform.origin.z),Vector3.UP)
				else:
					Rotate()
			else:
				Rotate()
		else:
			Rotate()
		is_rotating = true
	move_and_slide(-transform.basis.z*(traits.speed+traits.size*2)*delta,Vector3.UP)
		
func Rotate(index=random.randi_range(0,1)):
	var list = [-1,1]
	rotate_y(deg2rad(lerp(0,rotationSpeed*list[index],1)))
	is_rotating = true

func Wandering():
	if rotationTime.time_left <= 0.0:
		rotationTime = get_tree().create_timer(random.randi_range(1,8))
		is_rotating = false

func LifeCycle(delta):
	health.currentAmount -=(1+traits.speed*traits.size*traits.size/50 )*delta
	if health.currentAmount <= 0 :
		queue_free()

func Regenerate(ammount):
	food_counter +=1
	health.currentAmount += ammount
	is_rotating = false
	rotationTime.set_time_left(trackTimer) 
	looking_at = false



func Mutation():
	if(food_counter>=14):
		var play = player.instance();
		play.traits = deep_copy(traits)
		var map = 14
		var location = Vector3()
		if(transform.origin.x+1>map):
			location.x = transform.origin.x-1
		else:
			location.x = transform.origin.x+1
		location.y=2
		if(transform.origin.z+1>map):
			location.z = transform.origin.z-1
		else:
			location.z = transform.origin.z+1
		
		play = DefineTraits(play)
		
		
		var v = play.get_node("Vision").get_child(0)
		v.transform.origin.z = play.traits.vision_position
		play.scale = Vector3(play.traits.size,play.traits.size,play.traits.size) 
		play.transform.origin = location
		
		play.emit_signal("newGeneration",gen)
		play.emit_signal("newTraits",traits)
		var collection = self.get_parent()
		
		collection.add_child(play)
		food_counter = 0
		

	
func DefineTraits(play):

	play.gen=gen+1
	var ran =int( rand_range(0,3))
	if ran == 0:

		play.traits.size= traits.size + rand_range(-0.1,0.1)
	elif ran == 1:

		play.traits.speed = traits.speed + rand_range(-20,20)
#		play.traits.vision_size = abs(traits.vision_size + rand_range(-1,1))
	elif ran == 2:
		play.traits.vision_position = traits.vision_position + rand_range(-1,1)
		if(abs(play.traits.vision_position)<=play.traits.vision_size):
			if(play.traits.vision_position<0):
				play.traits.vision_position = traits.vision_position + rand_range(0,1)
			else:
				play.traits.vision_position = traits.vision_position + rand_range(-1,0)
	
	return play
	
func food_required():
	if(eyes.is_colliding()):
		var item = eyes.get_collider()
		if(item != null):
			if(item.is_in_group("Food")):
				return false
	return true

func _on_Vision_area_entered(area):
	if(food_required() and area.is_in_group("Food")):
		is_rotating = true
		trackTimer = rotationTime.get_time_left() 
		rotationTime.set_time_left(rand_range(2,10)) 
		look_at(Vector3(area.global_transform.origin.x,global_transform.origin.y,area.global_transform.origin.z),Vector3.UP)
		looking_at =true


func _on_Vision_area_exited(area):
	if(food_required() and area.is_in_group("Food")):
		is_rotating = true
		trackTimer = rotationTime.get_time_left() 
		rotationTime.set_time_left(rand_range(2,10)) 
		look_at(Vector3(area.global_transform.origin.x,global_transform.origin.y,area.global_transform.origin.z),Vector3.UP)
		looking_at =true
		
		

static func deep_copy(v):
	var t = typeof(v)

	if t == TYPE_DICTIONARY:
		var d = {}
		for k in v:
			d[k] = deep_copy(v[k])
		return d

	elif t == TYPE_ARRAY:
		var d = []
		d.resize(len(v))
		for i in range(len(v)):
			d[i] = deep_copy(v[i])
		return d

	elif t == TYPE_OBJECT:
		if v.has_method("duplicate"):
			return v.duplicate()
		else:
			print("Found an object, but I don't know how to copy it!")
			return v

	else:
		# Other types should be fine,
		# they are value types (except poolarrays maybe)
		return v
