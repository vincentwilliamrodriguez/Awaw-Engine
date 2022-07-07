extends KinematicBody2D

var BR = preload("res://Flappy Bird/Brain.cs")

var v = Vector2(0,0)
var isAI = false
var brain
var rng = RandomNumberGenerator.new()
var nearest_pipe = null

signal gameOver

func _ready():
	brain = BR.new()
	brain.Init(P.DEFAULT_NN_SIZE)

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
	if is_instance_valid(nearest_pipe):
		var bird_y = inverse_lerp(0, 5689, position.y)
		var pipe_x = inverse_lerp(0, 2560, nearest_pipe.position.x)
		var top_y = inverse_lerp(0, 5689, nearest_pipe.position.y)
		var bottom_y = inverse_lerp(0, 5689, nearest_pipe.position.y + P.GAP)
		var output = brain.FeedForward([bird_y, pipe_x, top_y, bottom_y])
		
		if output[0] > 0.5:
			Jump()
