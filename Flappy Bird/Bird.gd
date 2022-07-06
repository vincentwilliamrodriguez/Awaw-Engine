extends KinematicBody2D

var v = Vector2(0,0)
var isAI = false

signal gameOver

func _ready():
	pass # Replace with function body.

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

func _input(event):
	if event.is_action_pressed("click") or event.is_action_pressed("space"):
		v.y = P.JUMP_HEIGHT

func Apply(x, y):
	v += Vector2(x, y)

func GameOver():
	if !isAI:
		emit_signal("gameOver")
	queue_free()
