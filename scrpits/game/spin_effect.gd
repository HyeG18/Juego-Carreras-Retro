extends Node

@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	player.spin_effect.connect(on_player_spin_effect)

func on_player_spin_effect() -> void:
	player.is_spinning = true
