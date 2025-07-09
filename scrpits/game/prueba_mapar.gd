extends Control

@onready var race_timer = $RaceTimer
@onready var race_label = $RaceTimerLabel
var elapsed_time := 0.0

func _ready():
	elapsed_time = 0.0
	race_timer.start()
	set_process(true)

func _process(delta):
	elapsed_time += delta
	race_label.text = format_time(elapsed_time)
	print(format_time(elapsed_time))

func format_time(time_sec: float) -> String:
	var minutes = int(time_sec / 60)
	var seconds = int(time_sec) % 60
	var milliseconds = int((time_sec - int(time_sec)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
