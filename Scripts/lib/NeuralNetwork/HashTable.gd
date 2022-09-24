extends Node
var Perception ={}

func AddToDec(id,output):
    Perception[id]=output

func GetOutputForId(id):
    return Perception.get(id)