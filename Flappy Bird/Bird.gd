extends KinematicBody2D

var BR = preload("res://Flappy Bird/Brain.cs")

var v = Vector2(0,0)
var isAI = false
var brain
var rng = RandomNumberGenerator.new()

signal gameOver

func _ready():
	brain = BR.new()
	brain.Init(P.DEFAULT_NN_SIZE)
	brain.FeedForward([0.5, -0.5, 1, 0.5])

func _physics_process(delta):
	Apply(0, P.GRAVITY * delta)
	
	v.y = clamp(v.y, P.V_LIMIT_UP, P.V_LIMIT_DOWN)
	var collided = move_and_collide(v * delta)
	
	if collided:
		GameOver()
	
	if v.y < P.ROTATION_THRESHOLD:
		rotation_degrees = -20
	else:
		rotation_degrees = lerp(-20, 60, (v.y - P.ROTATION_THRESHOLD) / (P.V_LIMIT_DOWN - P.ROTATION_THRESHOLD))
		
	Think()

func _input(event):
	if event.is_action_pressed("click") or event.is_action_pressed("space"):
		Jump()

func Apply(x, y):
	v += Vector2(x, y)

func GameOver():
	if !isAI:
		emit_signal("gameOver", self)
	queue_free()
	brain.queue_free()

func Jump():
	if position.y > 0:
		v.y = P.JUMP_HEIGHT

func Think():
	rng.randomize()
	if rng.randf() < 0.05:
		Jump()
