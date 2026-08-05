extends Node2D

func _input(e):
	if e is InputEventMouseButton:
		var menu = preload("res://escenas/menu.tscn").instantiate()
		get_tree().root.add_child(menu)
		queue_free()
		get_tree().current_scene = menu

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	var menu = preload("res://escenas/menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	queue_free()
	get_tree().current_scene = menu
