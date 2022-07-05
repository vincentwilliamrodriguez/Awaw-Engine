extends Timer


func _ready():
	pass

func _on_Timer_timeout():
	for b in get_node("../Birds").get_children():
		print(b.name, ': ', b.position)
	print()
