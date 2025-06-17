extends Node

@onready var player: CharacterBody2D = $".."
@onready var run_effect_timer: Timer = $Run_effect_Timer

const EFFECT_DURATION: int = 2  #dura 2 segundos el efecto

func _ready() -> void:
	player.run_effect.connect(on_player_run_effect)
	run_effect_timer.timeout.connect(on_time_out)

func on_player_run_effect() -> void:
	player.debe_correr = true
	run_effect_timer.start(EFFECT_DURATION)

func on_time_out() -> void:
	player.debe_correr = false
