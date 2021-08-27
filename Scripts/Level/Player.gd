extends KinematicBody
signal newGeneration(oldGen)
signal newTraits(traits)
var neuron = preload("res://Scripts/lib/NN.gd")
onready var healthBar = $HealthBar3D/Viewport/HealthBar
onready var Gen = $HealthBar3D/Viewport/HealthBar/Generation/GenNumber
onready var Traits = $HealthBar3D/Viewport/HealthBar/Speed/SpeedNumber
onready var health = $Health
var ai_data = "user://score.save"


var traits = {
	"id":0,
	"gender":'M',
	"speed":rand_range(20,40),
	"size":rand_range(0.4,0.6)
}

var gen=0
var food_counter = 0
var trackTimer = 0
var size = 14
var gravity = 12
var velocity=Vector3()
var random = RandomNumberGenerator.new()
var rotationTime
var globalDelta = 0
var ReproductionDesire = 0 
var NeuralNetwork 

var Age=0
var noOfClild=0
var timer

onready var vp = get_node("Eyes/ViewportContainer/Viewport")

func _ready():
	timer = get_tree().create_timer(5)
	var img = vp.get_texture().get_data()
	img.flip_y()
	var height = img.get_height()
	var width = img.get_width()
	var camera = vp.get_child(0)
	camera.near = traits.size+0.01
	scale = Vector3(traits.size,traits.size,traits.size)

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
	var camera = vp.get_child(0)
	
	if timer.time_left <= 0.0:
		Age+=1
		timer = get_tree().create_timer(5)
	var result =DecisionMaking()
#	for i in range(len(result)):
#		result[i]=result[i]/100000000
	velocity = -transform.basis.z*result[0]*traits.speed
	if not is_on_floor():
		velocity.y-=gravity*delta
	move_and_slide(velocity.normalized(),Vector3.UP)

	camera.transform.origin=transform.origin 
	camera.rotate_y(-lerp(0,traits.speed/200,result[1]))
	rotate_y(-lerp(0,traits.speed/200,result[1]))

	if(result[2]<0):
		ReproductionDesire=0
	else:
		ReproductionDesire=1
	LifeCycle(delta)

func DecisionMaking():
	var input = []
	var img = vp.get_texture().get_data()
	img.flip_y()
	var height = img.get_height()
	var width = img.get_width()
	img.lock()
	for i in range(height):
		for j in range(width):
			input.append(rgbToDecimal(img.get_pixel(i,j)))
	input.append(health.currentAmount)
	input.append(ReproductionDesire)
	var output = NeuralNetwork.Run(input)
	return output
func LifeCycle(delta):
	health.currentAmount -=(1 +traits.speed*traits.size*traits.size/50 )*delta
	if health.currentAmount <= 0 :
		var data = {
			"gender":"M",
			"fitness": Age+noOfClild*2,
			"NN":NeuralNetwork.GetNN()
		}
		var file = File.new()
		var AllData =[]
		if file.file_exists(ai_data):
			file.open(ai_data, File.READ)
			AllData = file.get_var(true)
			file.close()
			var male = []
			for x in AllData :
				if (x.gender=="M"):
					male.append(x)
			
			if(len(male)==2):
				var index =-1
				for i in range(len(AllData)):
					if(AllData[i].gender=="M" and AllData[i].fitness<data.fitness):
						index=i
				if(index!=-1):
					AllData[index]=data
			else:
				AllData.append(data)
		else:
				AllData.append(data)
		file.open(ai_data, File.WRITE)
		file.store_var(AllData, true)
		file.close()
		queue_free()

func Regenerate(ammount):
	health.currentAmount += ammount

func WannaReproduce():
	if(ReproductionDesire==1):
		return true
	else:
		return false
#
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
static func rgbToDecimal(img):
	var result = (img[0] * 256 * 256* 256) + (img[1] * 256* 256) + (img[2]* 256) +img[3]
	return result
func GetTraits():
	return traits



func _on_Area_body_entered(body):
	if(body.is_in_group("Player") and body.traits.id != traits.id and body.traits.gender == 'F' ):
		if(ReproductionDesire==1):
			if(body.WannaReproduce()):
				ReproductionDesire=0
#				noOfClild+=1
#				body.Repoduction(traits)
			else:
				pass
