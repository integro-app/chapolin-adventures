extends Node2D

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#13263d"))
	draw_rect(Rect2(0, 300, 640, 60), Color("#4b6a49"))

func _ready() -> void:
	queue_redraw()
