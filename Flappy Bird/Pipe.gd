extends StaticBody2D

signal score
var pipe_number
var pipe_state
var passed = false

func _ready():
	pass
	
func Init(state, number, y):
	$Pipe.flip_v = state
	$Pipe.offset.y = 0 if state else -243
	
	$CollisionShape2D.position.y *= 1 if state else -1
	
	name = ["Top ", "Bottom "][state] + str(number)
	
	position.y = y
	pipe_number = number
	pipe_state = state
	
func _physics_process(delta):
	position.x -= P.SPEED * delta
	
	if !passed and position.x < 640 and !pipe_state:
		emit_signal("score", pipe_number)
		passed = true
		
	if position.x < -445:
		queue_free()
