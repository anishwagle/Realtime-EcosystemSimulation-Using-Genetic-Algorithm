extends Spatial
var random = RandomNumberGenerator.new()
var player = preload("res://Assets/Level/Player/Player.tscn")
var player_f = preload("res://Assets/Level/Player/Player_F.tscn")
var neuron = preload("res://Scripts/lib/NN.gd")
var ai_data = "user://score.save"
var gen = "user://gen.save"
var number = 5
var location = Vector3()
var size = 14
var generation = 0
var vHeight = 30
var vWidth = 30
var networkString
func _process(delta):
	if(get_child_count()==0):
		
		
		random.randomize()
		var counter = 0
		var file = File.new()
		var AllData = []
		var new = false
		if file.file_exists(ai_data):
			file.open(ai_data, File.READ)
			AllData = file.get_var(true)
			file.close()
			file.open(gen, File.READ)
			generation = file.get_var(true) +1
			file.close()
			file.open(gen, File.WRITE)
			file.store_var(generation, true)
			file.close()
			if(len(AllData)==0):
				new=true
			else:
				var male=[]
				var female=[]
				for data in AllData:
					if(data.gender=="M"):
						male.append(data)
					if(data.gender=="F"):
						female.append(data)
			
				for m in male:
					for f in female:
						counter +=1
						if(counter<number*2):
							location.x = rand_range(-size,size)
							location.y = 1
							location.z = rand_range(-size,size)
							var child
							
							if(counter<=number):
								child =initPop(player,counter)
							else:
								child =initPop(player_f,counter)


							var n1 = neuron.new(vHeight*vWidth+2,3)
							n1.SetNN(m.NN)
							child.NeuralNetwork = neuron.new(vHeight*vWidth+2,3)
							child.NeuralNetwork.SetNN(n1.CrossOver(f.NN))
							child.NeuralNetwork.CleanUp()
							var mutation = rand_range(0,100)
							if(mutation<2):
								child.NeuralNetwork.Mutation()
							networkString = child.NeuralNetwork.GetNN()
							add_child(child)
		else:
			new = true
		if(new):
			generation = 0
			file.open(gen, File.WRITE)
			file.store_var(generation, true)
			file.close()
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
		print(generation)
		
func initPop(player,i):
	var fo = player.instance()
	fo.traits.id = i + 1
	fo.transform.origin = location
	return fo
