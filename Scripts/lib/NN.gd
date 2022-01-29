extends Node

var random = RandomNumberGenerator.new()
var NN = {
	"Nodes":[],
	"Connections":[]
}

func _init(inputNo,outputNo):
	random.randomize()
	var outputName = 0
	for input in range(inputNo):
		var node = {
			'Node':input,
			'Type':"Input",
			'Bias':random.randf_range(-1,1),
			'Output':0
		}
		NN.Nodes.append(node)
		outputName = input
	outputName+=1
	for output in range(outputNo):
		var node = {
			'Node':output+outputName,
			'Type':"Output",
			'Bias':random.randf_range(-1,1),
			'Output':0
		}
		NN.Nodes.append(node)
#	var Innov=0
#	for input in range(inputNo):
#		for output in range(outputNo):
#			var connection ={
#			'In':input,
#			'Out':output+outputName,
#			'Weight':random.randf_range(-1,1),
#			'Enable':true,
#			'Innov':Innov+1
#			}
#			Innov=Innov+1
#			NN.Connections.append(connection)
	
	
func AddConnection(inputNode,OutputNode):
	random.randomize()
	for connection in NN.Connections:
		if(connection.In==inputNode and connection.Out==OutputNode):
			return
	var Innov=0
	if(len(NN.Connections)==0):
		Innov=0
	else:
		Innov=NN.Connections[len(NN.Connections)-1].Innov + 1
	var connection ={
		'In':inputNode,
		'Out':OutputNode,
		'Weight':random.randf_range(-1,1),
		'Enable':true,
		'Innov':Innov
	}
	NN.Connections.append(connection)

func AddNode(innov):
	var node = {
			'Node':len(NN.Nodes),
			'Type':"Hidden",
			'Bias':random.randf_range(-1,1),
			'Output':0
		}
	NN.Nodes.append(node)
	var Index = 0
	for index in len(NN.Connections):
		if(NN.Connections[index].Innov==innov):
			Index=index
			break
	NN.Connections[Index].Enable=false
	var inputNode=NN.Connections[Index].In
	var outputNode=NN.Connections[Index].Out
	var weight=NN.Connections[Index].Weight
	var Innov=0
	if(len(NN.Connections)==0):
		Innov=0
	else:
		Innov=NN.Connections[len(NN.Connections)-1].Innov + 1
	var connection={
		'In':inputNode,
		'Out':node.Node,
		'Weight':1,
		'Enable':true,
		'Innov':Innov
	}
	var connection1={
		'In':node.Node,
		'Out':outputNode,
		'Weight':weight,
		'Enable':true,
		'Innov':Innov+1
	}
	NN.Connections.append(connection)
	NN.Connections.append(connection1)

func RemoveNode(node):
	var outputList=[]
	for connection in NN.Connections:
		if(connection.In==node):
			outputList.append(connection.Out)
	var NodeList=[]
	for connection in range(len(NN.Connections)):
		if(NN.Connections[connection].Out==node or NN.Connections[connection].In==node ):
			NodeList.append(connection)
	for i in range(len(NodeList)):
		NN.Connections.remove(NodeList[i])
	for connection in range(len(NN.Connections)):
		if(NN.Connections[connection].Out in outputList):
			NN.Connections[connection].Enable = true
	var Index=0
	for i in range(len(NN.Nodes)):
		if(NN.Nodes[i].Node==node):
			Index=i
			break
	NN.Nodes.remove(Index)

func RemoveConnection(Innov):
	var Index = 0
	for i in range(len(NN.Connections)):
		if(NN.Connections[i].Innov==Innov):
			Index=i
	NN.Connections.remove(Index)

func Activation(output):
	var e = 2.718281828
	return output/(1+pow(e,-output))

func Run(input):
	var output=[]
	for i in range(len(input)):
		NN.Nodes[i].Output=input[i]
	for i in NN.Nodes:
		if i.Type!="Input":
			Neuron(i.Node)
	for i in NN.Nodes:
		if i.Type=="Output":
			output.append(i.Output)
	return output

func Neuron(node):
	var output = 0
	var inputList=[]
	var InputNodes=[]
	for connection in NN.Connections:
		if(connection.Out==node and connection.Enable):
			InputNodes.append({'In':connection.In,'Weight':connection.Weight})
	for input in InputNodes:
		inputList.append(NN.Nodes[FindIndexFromNode(NN.Nodes,input.In)].Output)##input name doesnot always gurienty node position
	for i in range(len(inputList)):
		output+=inputList[i]*InputNodes[i].Weight
	output+=NN.Nodes[FindIndexFromNode(NN.Nodes,node)].Bias
	NN.Nodes[FindIndexFromNode(NN.Nodes,node)].Output=Activation(output)

func Mutation():
	random.randomize()
	var case=0
	var hiddennodes = []
	for node in NN.Nodes:
		if node.Type=="Hidden":
			hiddennodes.append(node.Node)
	var InnovList=[]
	for connection in NN.Connections:
		if(connection.Enable):
			InnovList.append(connection.Innov)
	var index=0
	if(len(InnovList)==0):
		case = 0
	elif len(hiddennodes)==0:
		case = random.randi_range(0,2)
		index = random.randi_range(0,len(InnovList)-1)
	else:
		case = random.randi_range(0,3)
	match(case):
		0:
			var inputNodes=[]
			var outputNodes=[]
			for node in NN.Nodes:
				if node.Type!="Input":
					outputNodes.append({'node':node.Node,'type':node.Type})
				if node.Type!="Output":
					inputNodes.append({'node':node.Node,'type':node.Type})
			var input_index = random.randi_range(0,len(inputNodes)-1);
			var output_index = random.randi_range(0,len(outputNodes)-1);
			while(input_index==output_index):
				output_index = random.randi_range(0,len(outputNodes)-1);
			var inputNode = inputNodes[input_index]
			var outputNode = outputNodes[output_index]
			if(inputNode.node>outputNode.node and outputNode.type!="Output"):
				var temp=inputNode
				inputNode=outputNode
				outputNode=temp
			AddConnection(inputNode.node,outputNode.node)
		1:
			RemoveConnection(InnovList[index])
		2:
			if len(NN.Connections)==0:
				var inputNodes=[]
				var outputNodes=[]
				for node in NN.Nodes:
					if node.Type!="Input":
						outputNodes.append({'node':node.Node,'type':node.Type})
					if node.Type!="Output":
						inputNodes.append({'node':node.Node,'type':node.Type})
				var input_index = random.randi_range(0,len(inputNodes)-1);
				var output_index = random.randi_range(0,len(outputNodes)-1);
				while(input_index==output_index):
					output_index = random.randi_range(0,len(outputNodes)-1);
				var inputNode = inputNodes[input_index]
				var outputNode = outputNodes[output_index]
				if(inputNode.node>outputNode.node and outputNode.type!="Output"):
					var temp=inputNode
					inputNode=outputNode
					outputNode=temp
				AddConnection(inputNode.node,outputNode.node)
			AddNode(InnovList[index])
		3:
			var nodeIndex=random.randi_range(0,len(hiddennodes)-1)
			RemoveNode(hiddennodes[nodeIndex])
	CleanUp()

func CleanUp():
	var outNodeList=[]
	var inputNodeList=[]
	for i in NN.Connections:
		outNodeList.append(i.In)
		inputNodeList.append(i.Out)
	for n in NN.Nodes:
		if not(n.Type =="Input" or n.Type =="Output"):
			if not (n.Node  in outNodeList and n.Node  in inputNodeList):
				RemoveNode(n.Node)
				CleanUp()
	
func GetNN():
	return NN

func SetNN(NN1):
	NN=NN1
#cross over removes the input and output nodes 
func CrossOver(NN2,i_o_length):
	random.randomize()
	var NN_Child = {
		"Nodes":[],
		"Connections":[]
		}
	for i in range(i_o_length):
		var case = random.randi_range(0,2)
		if(case<1):
				NN_Child.Nodes.append(NN.Nodes[i])
		else:
			NN_Child.Nodes.append(NN2.Nodes[i])
		
	var N1_connection_length = len(NN.Connections)-1
	var N2_connection_length = len(NN2.Connections)-1
	var N1_Innov = []
	var N2_Innov = []
	for connection in NN.Connections:
		N1_Innov.append(connection.Innov)
	for connection in NN2.Connections:
		N2_Innov.append(connection.Innov)
	var int_Innov = Intraction(N1_Innov,N2_Innov)
	var N1_Indexes = []
	var N2_Indexes = []
	for item in int_Innov:
		N1_Indexes.append(FindIndexFromInnov(NN.Connections,item))
		N2_Indexes.append(FindIndexFromInnov(NN2.Connections,item))

#	if(fitness.N2>fitness.N1):
	for connection in NN2.Connections:
		if(not connection.Innov  in int_Innov):
			NN_Child.Connections.append(connection)
#	else:
	for connection in NN.Connections:
		if(not connection.Innov  in int_Innov):
			NN_Child.Connections.append(connection)
	for connection_index in range(len(int_Innov)):
		var case = random.randi_range(0,2)
		match(case):
			0:
				NN_Child.Connections.append(NN.Connections[N1_Indexes[connection_index]])
			1:
				NN_Child.Connections.append(NN2.Connections[N2_Indexes[connection_index]])
	var input_nodes = []
	var output_nodes = []
	for connection in NN_Child.Connections:
		input_nodes.append(connection.In)
		output_nodes.append(connection.Out)
	var nodes = Union(input_nodes,output_nodes)

	for node in nodes:
		var case = random.randi_range(0,2)
		match(case):
			0:
				for N1_node in NN.Nodes:
					if(N1_node.Node == node and not(N1_node in NN_Child.Nodes)):
						NN_Child.Nodes.append(N1_node)
			1:
				for N2_node in NN2.Nodes:
					if(N2_node.Node == node and not(N2_node in NN_Child.Nodes)):
						NN_Child.Nodes.append(N2_node)
#	NN_Child.CleanUp()
	return NN_Child

func Intraction(lst1, lst2):
	var final_list = []
	for itm in lst1:
		if(itm in lst2):
			final_list.append(itm)
	for itm in lst2:
		if(itm in lst1):
			if(not final_list.has(itm)):
				final_list.append(itm)
	return final_list

func FindIndexFromInnov(list,item):
	var index = -1
	for i in len(list):
		if(list[i].Innov==item):
			index=i
			break
	return index

func FindIndexFromNode(list,item):
	var index = -1
	for i in len(list):
		if(list[i].Node==item):
			index=i
			break
	return index

func Union(lst1, lst2):
	var final_list = []
	for itm in lst1:
		final_list.append(itm)
	for itm in lst2:
		if(not final_list.has(itm)):
			final_list.append(itm)
	return final_list
