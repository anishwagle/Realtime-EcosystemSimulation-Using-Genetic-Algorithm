extends Node
var RANDOM = RandomNumberGenerator.new();
var Perceptron = preload("./Perceptron.gd")
var Connection = preload("./Connection.gd")
var NN = {
	"Perceptrons":[],
	"Connections":[]
}

func _init(inputNo,outputNo):
	RANDOM.randomize()
	var outputName = 0
	for input in range(inputNo):
		var node = Perceptron.new(input,"I")
		NN.Perceptrons.append(node)
		outputName = input
	outputName+=1
	for output in range(outputNo):
		var node = Perceptron.new(output+outputName,"O")
		NN.Perceptrons.append(node)
	for input in range(inputNo):
		for output in range(outputNo):
			var connection = Connection.new(input,output+outputName,str(input)+"_"+str(output+outputName))
			NN.Connections.append(connection)



func GetNN():
	return NN


func AddNode(innov):
	var name = GetNewHiddenName()
	var node = Perceptron.new(name,"H")
	NN.Perceptrons.append(node)
	var index = GetConnectionIndex(innov)
	NN.Connections[index].Enable = false
	var connection1 = Connection.new(NN.Connections[index].Input,name,str(NN.Connections[index].Input)+"_"+str(name))
	connection1.Weight = 1
	var connection2 = Connection.new(name,NN.Connections[index].Out,str(name)+"_"+str(NN.Connections[index].Out))
	connection2.Weight = NN.Connections[index].Weight
	NN.Connections.append(connection1)
	NN.Connections.append(connection2)
# Recursion has error 
# recursion is fine, remove connections as well when removing node
# when looping and updating same list, issue arises
func RemoveConnection(innov):
	var index = GetConnectionIndex(innov)
	var inputIndex = GetPerceptronIndex(NN.Connections[index].Input)
	var outputIndex = GetPerceptronIndex(NN.Connections[index].Out)
	var iNode = NN.Perceptrons[inputIndex]
	var oNode = NN.Perceptrons[outputIndex]
	NN.Connections.remove(index)
	var oNodes = GetOutputNodes(iNode.Name)
	var iNodes = GetInputNodes(oNode.Name)
	if(len(oNodes)==0):
		NN.Perceptrons.remove(inputIndex)
		for c in NN.Connections:#issue region
			if(c.Out == iNode.Name):
				RemoveConnection(c.Innov)
	if(len(iNodes)==0):
		NN.Perceptrons.remove(outputIndex)
		for c in NN.Connections:#issue region
			if(c.Input == oNode.Name):
				RemoveConnection(c.Innov)
	return 0

func AddConnection(iname,oname):
	if(iname == oname):
		return
	RANDOM.randomize()
	var filtered =  FilterWithType()
	OrderNode(filtered.O)
	var iOrder = NN.Perceptron[GetPerceptronIndex(iname)].Order
	var oOrder = NN.Perceptron[GetPerceptronIndex(oname)].Order
	if(oOrder>iOrder):
		var tem = iname
		iname = oname
		oname = tem
	var connection = Connection.new(iname,oname,str(iname)+"_"+str(oname))
	NN.Connections.append(connection)

# func RemoveNode(node):
# 	NN.Perceptrons.remove(node)

# 	pass

func GetNewHiddenName():
	var data = FilterWithType()
	if(len(data.H)==0):
		return len(NN.Perceptrons)
	else:
		var name = 0
		for n in data.H:
			if(n.Name > name):
				name = n.Name
		return name +1

func OrderNode(array , order = 0):
	for node in array:
		UpdateOrder(node.Name,order)

	for node in array:
		var inputNodes = GetInputNodes(node.Name)
		if(len(inputNodes)==0):
			return
		else:
			OrderNode(inputNodes,order+1)

func UpdateOrder(name,order):
	var index = GetPerceptronIndex(name)
	NN.Perceptrons[index].Order = order

func GetPerceptronIndex(name):
	var index = -1;
	for item in NN.Perceptrons:
		index += 1
		if(name == item.Name):
			return index
	return -1

func GetConnectionIndex(innov):
	var index = -1;
	for item in NN.Connections:
		index += 1
		if(innov == item.Innov):
			return index
	return -1

func GetInputNodes(name):
	var response = [];
	for connection in NN.Connections:
		if( connection.Out == name):
			var index = GetPerceptronIndex(connection.Input)
			response.append(NN.Perceptrons[index])
	return response

func GetOutputNodes(name):
	var response = [];
	for connection in NN.Connections:
		if( connection.Input == name):
			var index = GetPerceptronIndex(connection.Out)
			response.append(NN.Perceptrons[index])
	return response

func FilterWithType():
	var response = {
		"I":[],
		"H":[],
		"O":[]
	}
	for item in NN.Perceptrons:
		if item.Type == "I":
			response.I.append(item)
		elif item.Type == "O":
			response.O.append(item)
		else:
			response.H.append(item)
	return response