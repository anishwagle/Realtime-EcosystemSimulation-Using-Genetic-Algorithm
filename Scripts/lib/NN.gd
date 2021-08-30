extends Node

var random = RandomNumberGenerator.new()
var NN = {
	"Nodes":[],
	"Connections":[]
}
var inputlength
var outputlength

func _init(inputNo,outputNo):
	inputlength = inputNo
	outputlength = outputNo
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
	var Innov=0
	for input in range(inputNo):
		for output in range(outputNo):
			var connection ={
			'In':input,
			'Out':output+outputName,
			'Weight':random.randf_range(-1,1),
			'Enable':true,
			'Innov':Innov+1
			}
			Innov=Innov+1
			NN.Connections.append(connection)
	
	
		
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
		NN.Connections.remove(NodeList[i]-i)
	for connection in range(len(NN.Connections)):
		if(NN.Connections[connection].Out in outputList):
			NN.Connections[connection].Enable = true
	var Index=0
	for i in range(len(NN.Nodes)):
		if(NN.Nodes[i].Node==node):
			Index=i
	NN.Nodes.remove(Index)

func RemoveConnection(Innov):
	var Index = 0
	for i in range(len(NN.Connections)):
		if(NN.Connections[i].Innov==Innov):
			Index=i
	NN.Connections.remove(Index)
#tanH
func Activation(output):
	var e = 2.718281828
	return (2/(1+pow(e,-2*output)))-1

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
			inputList.append(NN.Nodes[connection.In-1].Output)

	for i in range(len(inputList)):
		output+=inputList[i]*InputNodes[i].Weight
	output+=NN.Nodes[node].Bias
	NN.Nodes[node].Output=Activation(output)

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
			AddNode(InnovList[index])
		3:
			var nodeIndex=random.randi_range(0,len(hiddennodes)-1)
			RemoveNode(hiddennodes[nodeIndex])
	CleanUp()

func CleanUp():
	var outNodeList=[]
	var inputNodeList=[]
	for i in NN.Connections:
		if(i.Enable):
			outNodeList.append(i.In)
			inputNodeList.append(i.Out)
	for n in NN.Nodes:
		if (n.Type !="Input" and n.Type !="Output"):
			if not (n.Node  in outNodeList) or not (n.Node  in inputNodeList):
				RemoveNode(n.Node)
				CleanUp()
	
func GetNN():
	return NN

func SetNN(NN1):
	NN=NN1


func CrossOver(NN2):
	random.randomize()
	var NN_Child = {
		"Nodes":[],
		"Connections":[]
		}


	var N1_Node = []
	var N2_Node = []
	var N1_NodeIndexes = []
	var N2_NodeIndexes = []
	
	for node in len(NN.Nodes):
		N1_Node.append(NN.Nodes[node].Node)
		N1_NodeIndexes.append({"index":node,"node":NN.Nodes[node].Node})
		
	for node in len(NN2.Nodes):
		N2_Node.append(NN2.Nodes[node].Node)
		N2_NodeIndexes.append({"index":node,"node":NN2.Nodes[node].Node})

	var int_Node = Intraction(N1_Node,N2_Node)
	var total = inputlength + outputlength -1
	for node in range(total,len(NN2.Nodes)):
		if(not NN2.Nodes[node].Node  in int_Node):
			NN_Child.Node.append(NN2.Nodes[node])

	for node in range(total,len(NN.Nodes)):
		if(not NN.Nodes[node].Node  in int_Node):
			NN_Child.Node.append(node)
#This Part is bullshit
	for node_index in int_Node:
		var case = random.randi_range(0,1)
		match(case):
			0:
				var index;
				for i in N1_NodeIndexes:
					if i.node==node_index:
						index=i.index
						break
				NN_Child.Nodes.append(NN.Nodes[index])
			1:
				var index;
				for i in N2_NodeIndexes:
					if i.node==node_index:
						index=i.index
						break
				NN_Child.Nodes.append(NN2.Nodes[index])
#

	var N1_Innov = []
	var N2_Innov = []
	var N1_Indexes = []
	var N2_Indexes = []
	for connection in len(NN.Connections):
		N1_Indexes.append({"index":connection,"inov":NN.Connections[connection].Innov})
		N1_Innov.append(NN.Connections[connection].Innov)
		
	for connection in len(NN2.Connections):
		N2_Indexes.append({"index":connection,"inov":NN2.Connections[connection].Innov})
		N2_Innov.append(NN2.Connections[connection].Innov)
		

		
	var int_Innov = Intraction(N1_Innov,N2_Innov)
	

	for connection in NN2.Connections:
		if(not connection.Innov  in int_Innov):
			NN_Child.Connections.append(connection)

	for connection in NN.Connections:
		if(not connection.Innov  in int_Innov):
			NN_Child.Connections.append(connection)
#This Part is bullshit
	for connection_index in int_Innov:
		var case = random.randi_range(0,2)
		match(case):
			0:
				var index;
				for i in N1_Indexes:
					if i.inov==connection_index:
						index=i.index
						break
				
				NN_Child.Connections.append(NN.Connections[index])
			1:
				var index;
				for i in N2_Indexes:
					if i.inov==connection_index:
						index=i.index
						break
				NN_Child.Connections.append(NN2.Connections[index])
#

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


func Union(lst1, lst2):
	var final_list = []
	for itm in lst1:
		final_list.append(itm)
	for itm in lst2:
		if(not final_list.has(itm)):
			final_list.append(itm)
	return final_list
