extends Node;
var RANDOM = RandomNumberGenerator.new();
var Perception = preload("./Perception.gd")
var Connection = preload("./Connection.gd")
var HashTable = preload("./HashTable.gd")
var NN = {
	"Perceptions":[],
	"Connections":[]
}
var inputLength
var outputLength
var HS = HashTable.new();

func _init(inputNo,outputNo):
	inputLength = inputNo
	outputLength = outputNo

	RANDOM.randomize()
	var outputName = 0
	for input in range(inputNo):
		var node = Perception.new(input,"I")
		NN.Perceptions.append(node)
		outputName = input
	outputName+=1
	for output in range(outputNo):
		var node = Perception.new(output+outputName,"O")
		NN.Perceptions.append(node)
	for input in range(inputNo):
		for output in range(outputNo):
			var connection = Connection.new(input,output+outputName,str(input)+"_"+str(output+outputName))
			NN.Connections.append(connection)



func GetNN():
	return NN

func SetNN(NN1):
	NN=NN1

func AddNode(innov):
	var name = GetNewHiddenName()
	var node = Perception.new(name,"H")
	NN.Perceptions.append(node)
	var index = GetConnectionIndex(innov)
	NN.Connections[index].Enable = false
	var connection1 = Connection.new(NN.Connections[index].Input,name,str(NN.Connections[index].Input)+"_"+str(name))
	connection1.Weight = 1
	var connection2 = Connection.new(name,NN.Connections[index].Out,str(name)+"_"+str(NN.Connections[index].Out))
	connection2.Weight = NN.Connections[index].Weight
	NN.Connections.append(connection1)
	NN.Connections.append(connection2)

func RemoveConnection(innov):
	var index = GetConnectionIndex(innov)
	NN.Connections.remove(index)
	RemoveNodeWithNoConnections()

func RemoveNodeWithNoConnections():
	var filtered =  FilterWithType()
	for item in filtered.H:
		var inputNodes = GetInputNodes(item.Name);
		var outputNodes = GetOutputNodes(item.Name);
		if len(inputNodes) == 0 :
			NN.Perceptions.remove(GetPerceptionIndex(item.Name))
			for out in outputNodes:
				var index = GetConnectionIndex(str(item.Name)+"_"+str(out.Name))
				NN.Connections.remove(index)
			RemoveNodeWithNoConnections()
		if len(outputNodes) == 0:
			NN.Perceptions.remove(GetPerceptionIndex(item.Name))
			for input in inputNodes:
				var index = GetConnectionIndex(str(input.Name)+"_"+str(item.Name))
				NN.Connections.remove(index)
			RemoveNodeWithNoConnections()

func AddConnection(iname,oname):
	if(iname == oname):
		return
	RANDOM.randomize()
	var filtered =  FilterWithType()
	OrderNode(filtered.O,len(NN.Perceptions))
	var iOrder = NN.Perceptions[GetPerceptionIndex(iname)].Order
	var oOrder = NN.Perceptions[GetPerceptionIndex(oname)].Order
	if(oOrder<iOrder):
		var tem = iname
		iname = oname
		oname = tem
	if(GetConnectionIndex(str(iname)+"_"+str(oname))!=-1):
		return
	var connection = Connection.new(iname,oname,str(iname)+"_"+str(oname))
	NN.Connections.append(connection)


func Mutation():
    RANDOM.randomize()
    var case=0
    var index=0
    var filteredNodes = FilterWithType();

    if(len(NN.Connections)==0):
        case = 0
    else:
        case = RANDOM.randi_range(0,2)
        index = RANDOM.randi_range(0,len(NN.Connections)-1)

    match(case):
        0:
            var inputNodes=filteredNodes.I + filteredNodes.H;
            var outputNodes= filteredNodes.O + filteredNodes.H;
            var input_index = RANDOM.randi_range(0,len(inputNodes)-1);
            var output_index = RANDOM.randi_range(0,len(outputNodes)-1);
            var inputNode = inputNodes[input_index]
            var outputNode = outputNodes[output_index]
            AddConnection(inputNode.Name,outputNode.Name)
        1:
            RemoveConnection(NN.Connections[index].Innov)
        2:
           AddNode(NN.Connections[index].Innov)


func CrossOver(parent2):
	RANDOM.randomize()
	var NN2 = parent2.NN
	var NN_Child = {
		"Perceptions":[],
		"Connections":[]
	}

	for i in range(inputLength+outputLength):
		var case = RANDOM.randi_range(0,1)
		if(case<1):
				NN_Child.Perceptions.append(NN.Perceptions[i])
		else:
			NN_Child.Perceptions.append(NN2.Perceptions[i])
		
	var N1_Innov = []
	var N2_Innov = []
	for connection in NN.Connections:
		N1_Innov.append(connection.Innov)
	for connection in NN2.Connections:
		N2_Innov.append(connection.Innov)
	var int_Innov = Intraction(N1_Innov,N2_Innov)

	for connection in NN2.Connections:
		if(not connection.Innov  in int_Innov):
			NN_Child.Connections.append(connection)

	for connection in NN.Connections:
		if(not connection.Innov  in int_Innov):
			NN_Child.Connections.append(connection)

	for item in int_Innov:
		var case = RANDOM.randi_range(0,1)
		match(case):
			0:
				NN_Child.Connections.append(NN.Connections[GetConnectionIndex(item)])
			1:
				NN_Child.Connections.append(NN2.Connections[parent2.GetConnectionIndex(item)])
	var input_nodes = []
	var output_nodes = []
	for connection in NN_Child.Connections:
		input_nodes.append(connection.Input)
		output_nodes.append(connection.Out)
	var nodes = Union(input_nodes,output_nodes)

	for node in nodes:
		var case = RANDOM.randi_range(0,1)
		match(case):
			0:
				for N1_node in NN.Perceptions:
					if(N1_node.Name == node and not(N1_node in NN_Child.Perceptions)):
						NN_Child.Perceptions.append(N1_node)
			1:
				for N2_node in NN2.Perceptions:
					if(N2_node.Name == node and not(N2_node in NN_Child.Perceptions)):
						NN_Child.Perceptions.append(N2_node)

	return NN_Child

func Activation(output):
	var e = 2.718281828
	return output/(1+pow(e,-output))

func Calculate(inputList):
	var filtered =  FilterWithType()
	for i in range(inputLength):
		NN.Perceptions[i].Output = inputList[i]
	var result = []
	for item in filtered.O:
		result.append(CalculateSum(item))
	return result
	
func CalculateSum(output):
	var inputs = []
	var sum
	var connectedNodes = GetInputConnections(output.Name)
	for input in connectedNodes:
		var tem = HS.GetOutputForId(input.Input)
		if(tem != null):
			inputs.append(tem)
		elif len(GetInputNodes(input.Input))==0:
			var result = NN.Perceptions[GetPerceptionIndex(input.Input)]
			if(result!=null):
				var s = {
					Input = result.Output,
					Weight = input.Weight,
					Enable = input.Enable
				}
				inputs.append(s)
				HS.AddToDec(result.Name,s)
		else:
			var newRes = NN.Perceptions[GetPerceptionIndex(input.Input)]
			if(newRes != null):
				sum = CalculateSum(newRes);
				var s = {
					Input = sum,
					Weight = input.Weight,
					Enable = input.Enable
				}
				HS.AddToDec(newRes.Name,s)
	sum = CalculateOutput(inputs)
	return sum

func CalculateOutput(inputs):
	var output = 0
	for input in inputs:
		if(input.Enable):
			output+= input.Input * input.Weight
	return Activation(output)

func GetNewHiddenName():
	var data = FilterWithType()
	if(len(data.H)==0):
		return len(NN.Perceptions)
	else:
		var name = 0
		for n in data.H:
			if(n.Name > name):
				name = n.Name
		return name +1

func OrderNode(array , order ):
	for node in array:
		UpdateOrder(node.Name,order)
		var inputNodes = GetInputNodes(node.Name)
		if node.Type=="I":
			UpdateOrder(node.Name,-1)
			
		else:
			OrderNode(inputNodes,order-1)
	return 0
# func ResetOrder():
# 	for item in NN.Perceptions:
# 		UpdateOrder(item.Name,0)
func UpdateOrder(name,order):
	var index = GetPerceptionIndex(name)
	NN.Perceptions[index].Order = order

func GetPerceptionIndex(name):
	var index = -1;
	for item in NN.Perceptions:
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
			var index = GetPerceptionIndex(connection.Input)
			response.append(NN.Perceptions[index])
	return response

func GetInputConnections(name):
	var response = [];
	for connection in NN.Connections:
		if( connection.Out == name):
			response.append(connection)
	return response

func GetOutputNodes(name):
	
	var response = [];
	for connection in NN.Connections:
		if( connection.Input == name):
			var index = GetPerceptionIndex(connection.Out)
			response.append(NN.Perceptions[index])
	return response

func FilterWithType():
	var response = {
		"I":[],
		"H":[],
		"O":[]
	}
	for item in NN.Perceptions:
		if item.Type == "I":
			response.I.append(item)
		elif item.Type == "O":
			response.O.append(item)
		else:
			response.H.append(item)
	return response

func Union(lst1, lst2):
	var final_list = []
	for itm in lst1:
		final_list.append(itm)
	for itm in lst2:
		if(not final_list.has(itm)):
			final_list.append(itm)
	return final_list

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