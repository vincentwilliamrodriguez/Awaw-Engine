extends Node2D

var bird_scene = preload("res://Flappy Bird/Bird.tscn")
var pipe_scene = preload("res://Flappy Bird/Pipe.tscn")
var NNV_scene = preload("res://Flappy Bird/NNV.tscn")
var rng = RandomNumberGenerator.new()
var dir = Directory.new()
var pipe_number = 1
var last_top_y = (4711 - P.GAP) / 2.0
var general_score = 0
var generation = 1
var birds_alive = P.BIRDS_N
var nearest_pipe = null
var best_score = 0
var history_csv = "Generation,BestTimeScore,AverageTimeScore\n"

func _ready():
	$PipeTimer.wait_time = P.PIPE_TIMER
	NewPipe()
	
	for n in P.BIRDS_N:
		AddBird(n)
		
	UpdateNNV($Birds.get_node(str(generation) + ' 0').brain)

func _process(_delta):
	var display_text1 = "Score: %s\nGeneration: %s" % [general_score, generation]
	var display_text2 = "Alive: %s\nBest Score: %s" % [birds_alive, best_score]
	get_node("GUI/Label1").text = display_text1
	get_node("GUI/Label2").text = display_text2
	
	for p in $Pipes.get_children():
		if p.position.x > 70:
			nearest_pipe = p
			break
			
	for b in $Birds.get_children():
		b.nearest_pipe = nearest_pipe
		
	Engine.time_scale = get_node("GUI/MarginContainer/HSlider").value

func _input(event):
	if event.is_action_pressed("r"):
		get_node("GUI/MarginContainer/HSlider").value = 1
	
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
	
	NewPipe()
	generation += 1
	
	var time_score_sum = 0
	var best_time_score = 0
	
	for bird in $"Vanished Birds".get_children():
		time_score_sum += bird.timeScore
		bird.timeScore2 = time_score_sum
		best_time_score = max(best_time_score, bird.timeScore)
	
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
		bird.brain.queue_free()
		bird.queue_free()
	
	var history_line = "%s,%s,%s\n" % [generation - 1, best_time_score, time_score_sum / P.BIRDS_N]
	history_csv += history_line
	best_score = max(best_score, general_score)
	
	ResetVariables()
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
	general_score += 1

func UpdateNNV(inp):
	get_node("NNV/Node2D").UpdateNN(inp)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		dir.remove("user://history.csv")
		
		var file = File.new()
		file.open("user://history.csv", File.WRITE)
		file.store_string(history_csv)
		file.close()
