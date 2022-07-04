extends Node2D

var bird_scene = preload("res://Flappy Bird/Bird.tscn")
var pipe_scene = preload("res://Flappy Bird/Pipe.tscn")

func _ready():
	for n in 1:
		AddBird(n)
		AddPipe(n)
	pass
	
func AddBird(n):
	var b = bird_scene.instance()
	
	b.name = str(n)
	b.position = Vector2(640,2356)
	b.connect("gameOver", self, "GameOver")
	
	$Birds.add_child(b)
	
func AddPipe(n):
	var p = pipe_scene.instance()
	
	p.name = str(n)
	p.position = Vector2(500,-500)
	
	$Pipes.add_child(p)

func GameOver():
	AddBird(1)
