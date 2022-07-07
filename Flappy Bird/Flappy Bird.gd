extends Node2D

var bird_scene = preload("res://Flappy Bird/Bird.tscn")
var pipe_scene = preload("res://Flappy Bird/Pipe.tscn")
var NNV_scene = preload("res://Flappy Bird/NNV.tscn")
var rng = RandomNumberGenerator.new()
var pipe_number = 1
var last_top_y = (4711 - P.GAP) / 2.0
var general_score = 0
var generation = 1
var birds_alive = P.BIRDS_N

func _ready():
	$PipeTimer.wait_time = P.PIPE_TIMER
	NewPipe()
	
	for n in P.BIRDS_N:
		AddBird(n)
		
	UpdateNNV($Birds.get_node(str(generation) + ' 0').brain)

func _process(_delta):
	get_node("GUI/CenterContainer/Label").text = str(general_score)

func AddBird(n):
	var b = bird_scene.instance()
	
	b.name = str(generation)+' '+str(n)
	b.position = Vector2(640,2356)
	b.connect("gameOver", self, "NextBird")
	
	$Birds.add_child(b)
	
func AddPipes():
	var ymin = max(500, last_top_y - P.PIPE_Y_RANGE)
	var ymax = min(4211 - P.GAP, last_top_y + P.PIPE_Y_RANGE)
	var top_y = rng.randf_range(ymin, ymax)
	var bottom_y = top_y + P.GAP
	
	for state in 2:
		var p = pipe_scene.instance()
		p.Init(state, pipe_number, bottom_y if state else top_y)
		p.position.x = 2560
		p.connect("score", self, "Score")
	
		$Pipes.add_child(p)

	last_top_y = top_y

func NextBird(bird):
	birds_alive -= 1
	if birds_alive == 0:
		GameOver(bird)

func GameOver(bird):
	for pipe in $Pipes.get_children():
		pipe.queue_free()
		
	ResetVariables()
	generation += 1
	
	for n in P.BIRDS_N:
		AddBird(n)
		
	UpdateNNV($Birds.get_node(str(generation) + ' 0').brain)
	
func NewPipe():
	AddPipes()
	pipe_number += 1
	$PipeTimer.start()

func ResetVariables():
	pipe_number = 1
	last_top_y = (4711 - P.GAP) / 2.0
	general_score = 0
	birds_alive = P.BIRDS_N

func Score(number):
	general_score = number

func UpdateNNV(inp):
	get_node("NNV/Node2D").UpdateNN(inp)

#	var mut = inp.Duplication()
#	mut.Mutate()
#	mut.FeedForward([0.5, -0.5, 1])
#	get_node("NNV2/Node2D").UpdateNN(mut)
