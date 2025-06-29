extends Node

@onready var players := {
	"1":{
		Viewport = $"HBoxContainer/SubViewportContainer/SubViewport",
		Camera = $"HBoxContainer/SubViewportContainer/SubViewport/Camera3D",
		player = $"HBoxContainer/SubViewportContainer/SubViewport/Mundo/Nissan GTR"
	},
	"2":{
		Viewport = $"HBoxContainer/SubViewportContainer2/SubViewport",
		Camera = $"HBoxContainer/SubViewportContainer2/SubViewport/Camera3D",
		player = $"HBoxContainer/SubViewportContainer/SubViewport/Mundo/Nissan GTR2"
	}
}
