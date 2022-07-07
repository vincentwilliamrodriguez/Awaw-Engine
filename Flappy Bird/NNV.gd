extends Node2D

var coordinates
var layers = []
var NN

func _ready():
	GenerateCoordinates()
	
func _process(_delta):
	update()

func _draw():
	for i in coordinates.size():
		for j in coordinates[i].size():
			if i != 0:
				for k in coordinates[i - 1].size():
					var w = NN.Retrieve("weights", i, j, k)
					var wn = (w + 1) / 2.0
					var w_color = Color(1 - wn,0,wn)
					
					draw_line(coordinates[i][j], coordinates[i - 1][k], w_color, 19 * abs(w) + 1, true)
			
			
			var n = NN.Retrieve("neurons", i, j)
			var nn = (n + 1) / 2.0
			var n_color = Color(nn, nn, nn)
			
			draw_circle(coordinates[i][j], 100, n_color)

func GenerateCoordinates():
	coordinates = []
	coordinates.resize(layers.size())
	
	for i in layers.size():
		coordinates[i] = []
		coordinates[i].resize(layers[i])
		
		for j in layers[i]:
			coordinates[i][j] = Vector2((2160 / (layers.size() - 1)) * i + 200, 300 * -((layers[i] - 1) / 2.0 - j) + 650)

func UpdateNN(inp):
	layers = inp.layers
	NN = inp
	GenerateCoordinates()
