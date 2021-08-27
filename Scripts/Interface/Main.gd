extends Spatial
#onready var Players = $Players
#var graph = preload("res://Assets/Interface/Graph.tscn")
#onready var speedGraph = $Graphs/SpeedGraph
#onready var populationGraph = $Graphs/PopulationGraph
#onready var sizeGraph = $Graphs/SizeGraph
#onready var graphs = $Graphs
#
#var showGraph = false
#var graphSize = 150
#var id = 0
#var speedData=[{'x':0,'y':75}]
#var populationData=[{'x':0,'y':15}]
#var sizeData=[{'x':0,'y':50}]
#var timer
#signal newSpeed(data,name)
#signal newPopulation(data,name)
#signal newSize(data,name)

func _ready():
	Engine.time_scale = 4
#
#	connect("newSpeed",speedGraph,"UpdateGraph")
#	connect("newPopulation",populationGraph,"UpdateGraph")
#	connect("newSize",sizeGraph,"UpdateGraph")
#	timer = get_tree().create_timer(15)
#
#func _process(delta):
#	if timer.time_left <= 0.0:
#		saveFile()
#		timer = get_tree().create_timer(5)
#func saveFile():
#	var players = Players.get_children()
#	var sum_speed = 0
#	var sum_size = 0
#	var count = 0
#
#	for player in players:
#		sum_speed += player.traits.speed
#		sum_size += player.traits.size*100
#		count += 1
#	var mean_speed = int(sum_speed/count)
#	var mean_size = int(sum_size/count)
#	id += 1 
#	speedData.append({'x':id,'y':mean_speed})
#	sizeData.append({'x':id,'y':mean_size})
#	populationData.append({'x':id,'y':count})
#	var speed = LoadData(speedData)
#	var size = LoadData(sizeData)
#	var population = LoadData(populationData)
#
#	if(showGraph):
#		emit_signal("newSpeed",speed,"Speed")
#		emit_signal("newPopulation",population,"Population")
#		emit_signal("newSize",size,"Size")
##	if data.size()>2:
#func LoadData(data):
#	var tempData
#
#	if data.size()<=graphSize:
#		tempData = data
#	else:
##		var step =int(populationData.size()/graphSize)
#		var startPoint = populationData.size() - graphSize
#
#		tempData = populationData.slice(startPoint,data.size())
#	return tempData
#
#
#
#func _on_Button_pressed():
#	if(showGraph):
#		speedGraph.visible=false
#		populationGraph.visible=false
#		sizeGraph.visible=false
#		showGraph=false
#	else:
#		speedGraph.visible=true
#		populationGraph.visible=true
#		sizeGraph.visible=true
#		showGraph=true
#		saveFile()
#	pass # Replace with function body.
#
#func _process(delta):
#	if timer.time_left <= 0.0:
#		saveFile()
#		timer = get_tree().create_timer(5)
#func saveFile():
#	var players = Players.get_children()
#	var sum_speed = 0
#	var sum_size = 0
#	var count = 0
#
#	for player in players:
#		sum_speed += player.traits.speed
#		sum_size += player.traits.size*100
#		count += 1
#	var mean_speed = int(sum_speed/count)
#	var mean_size = int(sum_size/count)
#	id += 1 
#	speedData.append({'x':id,'y':mean_speed})
#	sizeData.append({'x':id,'y':mean_size})
#	populationData.append({'x':id,'y':count})
#	var speed = LoadData(speedData)
#	var size = LoadData(sizeData)
#	var population = LoadData(populationData)
#
#	if(showGraph):
#		emit_signal("newSpeed",speed,"Speed")
#		emit_signal("newPopulation",population,"Population")
#		emit_signal("newSize",size,"Size")
##	if data.size()>2:
#func LoadData(data):
#	var tempData
#
#	if data.size()<=graphSize:
#		tempData = data
#	else:
##		var step =int(populationData.size()/graphSize)
#		var startPoint = populationData.size() - graphSize
#
#		tempData = populationData.slice(startPoint,data.size())
#	return tempData
#
#
#
#func _on_Button_pressed():
#	if(showGraph):
#		speedGraph.visible=false
#		populationGraph.visible=false
#		sizeGraph.visible=false
#		showGraph=false
#	else:
#		speedGraph.visible=true
#		populationGraph.visible=true
#		sizeGraph.visible=true
#		showGraph=true
#		saveFile()
#	pass # Replace with function body.
