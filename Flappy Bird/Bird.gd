extends KinematicBody2D

var BR = preload("res://Flappy Bird/Brain.cs")

var v = Vector2(0,0)
var brain
var rng = RandomNumberGenerator.new()
var nearest_pipe = null
var timeStarted = OS.get_ticks_msec()
var timeScore
var fitness
var fitnessCu
var VB

signal gameOver

func _ready():
	pass
	
func InitBrain():
	brain = BR.new()
	brain.Init(P.DEFAULT_NN_SIZE)
	rng.randomize()
	UpdateColor(rng.randf(), rng.randf(), rng.randf())

func _physics_process(delta):
	Apply(0, P.GRAVITY * delta)
	
	v.y = clamp(v.y, P.V_LIMIT_UP, P.V_LIMIT_DOWN)
	var collided = move_and_collide(v * delta)
	
	if collided or position.y < -214:
		set_physics_process(false)
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
	timeScore = OS.get_ticks_msec() - timeStarted
	timeScore *= Engine.time_scale
	timeScore = max(1, timeScore - (2060 / P.SPEED) * 1000)
	
	get_parent().remove_child(self)
	VB.add_child(self)
	hide()
	
	emit_signal("gameOver", self)

func Jump():
	if position.y > 0:
		v.y = P.JUMP_HEIGHT

func Think():
	if is_instance_valid(nearest_pipe):
		var bird_y = inverse_lerp(0, 5689, position.y)
		var pipe_x = inverse_lerp(0, 2560, nearest_pipe.position.x)
		var top_y = inverse_lerp(0, 5689, nearest_pipe.position.y)
		var bottom_y = inverse_lerp(0, 5689, nearest_pipe.position.y + P.GAP)
		var v_y = inverse_lerp(P.V_LIMIT_UP, P.V_LIMIT_DOWN, v.y)
		var output = brain.FeedForward([bird_y, pipe_x, top_y, bottom_y, v_y])
		
		if output[0] == 1:
			Jump()

func UpdateColor(r, g, b):
	$Bird.material.set_shader_param("inpr", r)
	$Bird.material.set_shader_param("inpg", g)
	$Bird.material.set_shader_param("inpb", b)
	
