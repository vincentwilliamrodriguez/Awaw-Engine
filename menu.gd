extends Control


func _ready():
	pass


func _on_Awaw_Chess_pressed():
	get_tree().change_scene("res://Chess/Awaw Chess Engine.tscn")

func _on_Flappy_Bird_pressed():
	get_tree().change_scene("res://Flappy Bird/Flappy Bird.tscn")
