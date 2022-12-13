extends Spatial
var random = RandomNumberGenerator.new()
var player = preload("res://Assets/Level/Player/Player.tscn")
var player_f = preload("res://Assets/Level/Player/Player_F.tscn")
var neuron = preload("res://Scripts/lib/NN.gd")
var testNeuron = preload("res://Scripts/lib/NeuralNetwork/NeuralNetwork.gd")
var ai_data = "user://fit.save"
var tem_population = "user://tem_fit.save"
var gen = "user://gen.save"
var number = 8
var location = Vector3()
var size = 14
var generation = 0
var vHeight = 30
var vWidth = 30
var networkString
func _ready():
	
#	var x1 =testNeuron.new(2,1)
#	var x2 =testNeuron.new(2,1)
#	var x3 =testNeuron.new(2,1)
#
#	var zzz = x3.GetNN()
#	var yyy = x1.Calculate([1,1])
	
#	Define Training Data
	var data = [
		{
			"I":[0,0],
			"O":0
		},
		{
			"I":[0,1],
			"O":1
		},
		{
			"I":[1,0],
			"O":1
		},
		{
			"I":[1,1],
			"O":0
		}
	]
	
#	AIs
	var ais = [];
	for _i in range(6):
		ais.append(testNeuron.new(2,1))
	
#	Train
	var counter = 0
	while counter<100:
		for d in data:
			var temAi = []
	#		ais.sort_custom(self,"sort_ai")
			
			for _i in range(9):
				random.randomize()		
				var tem = testNeuron.new(2,1)
				tem.SetNN(ais[random.randi_range(0,5)].CrossOver(ais[random.randi_range(0,5)]))
				if(1>random.randi_range(0,10)):
					tem.Mutation()
				temAi.append(tem)
			ais = temAi
			
			for ai in ais:
				var fitness = 0;
				var output = abs(ai.Calculate(d.I)[0]);
				fitness = abs(d.O - output)
				ai.SetFitness(fitness)
				var test123 = 0
			ais.sort_custom(self,"sort_ai")
		
		counter+=1
	var resul1 = abs(ais[0].Calculate([1,1])[0]);
	var resul2 = abs(ais[0].Calculate([0,1])[0]);
	var resul3 = abs(ais[0].Calculate([1,0])[0]);
	var resul4 = abs(ais[0].Calculate([0,0])[0]);
	var p =0
	pass
	
func sort_ai(a,b):
	return a.NN.Fitness < b.NN.Fitness;
	
func _process(delta):
	if(get_child_count()==0):
		random.randomize()
		var file = File.new()
		var AllData = []
		var temData = []
		var new = false
		if file.file_exists(ai_data):
			file.open(ai_data, File.READ)
			AllData = file.get_var(true)
			file.close()
			if file.file_exists(gen):
				file.open(gen, File.READ)
				generation = file.get_var(true) +1
				file.close()
			else:
				generation=1
			file.open(gen, File.WRITE)
			file.store_var(generation, true)
			file.close()
			if(len(AllData)==0):
				if file.file_exists(tem_population):
					file.open(tem_population, File.READ)
					temData = file.get_var(true)
					file.close()
					if(len(temData)==0):
						new=true
					else:
						AllData = temData
						genetic_impl(AllData)
				else:
					new=true
			else:
				genetic_impl(AllData)
			file.open(tem_population, File.WRITE)
			file.store_var(AllData, true)
			file.close()
			file.open(ai_data, File.WRITE)
			file.store_var([], true)
			file.close()
		else:
			new = true
		if(new):
			generation = 0
			file.open(gen, File.WRITE)
			file.store_var(generation, true)
			file.close()
			var counter = 0
			for i in range(number):
				counter+=1
				location.x = rand_range(-size,size)
				location.y = .25
				location.z = rand_range(-size,size)
				var child =initPop(player,i)
				child.NeuralNetwork = neuron.new(vHeight*vWidth+2,3)
				networkString = child.NeuralNetwork.GetNN()
				add_child(child)
			for i in range(number):
				counter+=1
				location.x = rand_range(-size,size)
				location.y = .25
				location.z = rand_range(-size,size)
				var child =initPop(player_f,i)
				child.NeuralNetwork = neuron.new(vHeight*vWidth+2,3)
				add_child(child)

func genetic_impl(AllData):
	var male=[]
	var female=[]
	for data in AllData:
		if(data.gender=="M"):
			male.append(data)
		if(data.gender=="F"):
			female.append(data)
	var counter = 0
	for m in male:
		for f in female:
			
			if(counter<number*2):
				location.x = rand_range(-size,size)
				location.y = 1
				location.z = rand_range(-size,size)
				var child
				
				if(counter<number):
					child =initPop(player,counter)
				else:
					child =initPop(player_f,counter)
				var n1 = neuron.new(vHeight*vWidth+2,3)
				n1.SetNN(m.NN)
				child.NeuralNetwork = neuron.new(vHeight*vWidth+2,3)
				child.NeuralNetwork.SetNN(n1.CrossOver(f.NN,vHeight*vWidth+2+3))
				networkString = child.NeuralNetwork.GetNN()
				child.NeuralNetwork.CleanUp()
				networkString = child.NeuralNetwork.GetNN()
#				var mutation = rand_range(0,100)
#				if(mutation<2):
				child.NeuralNetwork.Mutation()
				networkString = child.NeuralNetwork.GetNN()
				add_child(child)
				counter +=1


func initPop(player,i):
	var fo = player.instance()
	fo.traits.id = i + 1
	fo.transform.origin = location
	return fo
