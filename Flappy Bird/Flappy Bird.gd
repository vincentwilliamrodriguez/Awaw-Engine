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
var nearest_pipe = null

func _ready():
	$PipeTimer.wait_time = P.PIPE_TIMER
	NewPipe()
	
	for n in P.BIRDS_N:
		AddBird(n)
		
	UpdateNNV($Birds.get_node(str(generation) + ' 0').brain)

func _process(_delta):
	var display_text = "Score: %s\nGeneration: %s\nAlive: %s" % [general_score, generation, birds_alive]
	get_node("GUI/CenterContainer/Label").text = display_text
	
	for p in $Pipes.get_children():
		if p.position.x > 640:
			nearest_pipe = p
			break
			
	for b in $Birds.get_children():
		b.nearest_pipe = nearest_pipe

func AddBird(n):
	var b = bird_scene.instance()
	
	b.name = str(generation)+' '+str(n)
	b.position = Vector2(640,2356)
	b.VB = get_node("Vanished Birds")
	b.connect("gameOver", self, "NextBird")
	
	$Birds.add_child(b)
	return b
	
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

func NextBird(_bird):
	birds_alive -= 1
	if birds_alive > 0:
		UpdateNNV($Birds.get_child(0).brain)
	if birds_alive == 0:
		GameOver()

func GameOver():
	for pipe in $Pipes.get_children():
		pipe.free()
		
	ResetVariables()
	NewPipe()
	generation += 1
	
	var time_score_sum = 0
	for bird in $"Vanished Birds".get_children():
		time_score_sum += bird.timeScore
		bird.timeScore2 = time_score_sum
	
	for n in P.BIRDS_N:
		rng.randomize()
		var r = rng.randi_range(1, time_score_sum)
		for bird in $"Vanished Birds".get_children():
			if r <= bird.timeScore2:
				var new_bird = AddBird(n)
				var new_brain = bird.brain.Duplication()
				new_brain.Mutate()
				new_bird.brain = new_brain
				break
		
	for bird in $"Vanished Birds".get_children():
		bird.queue_free()
	
#	for n in P.BIRDS_N:
#		AddBird(n)
		
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
