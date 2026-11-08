extends Node2D

const SPEED := 190.0
const JUMP_SPEED := -350.0
const GRAVITY := 900.0
const FLOOR_Y := 300.0

var hero_pos := Vector2(120.0, FLOOR_Y)
var vertical_speed := 0.0
var move_axis := 0.0
var jump_requested := false

func _ready() -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("ui_left", "ui_right")
	if absf(axis) < 0.1:
		axis = move_axis
	hero_pos.x = clampf(hero_pos.x + axis * SPEED * delta, 14.0, 626.0)
	if (Input.is_action_just_pressed("ui_accept") or jump_requested) and hero_pos.y >= FLOOR_Y:
		vertical_speed = JUMP_SPEED
	jump_requested = false
	vertical_speed += GRAVITY * delta
	hero_pos.y = minf(hero_pos.y + vertical_speed * delta, FLOOR_Y)
	if hero_pos.y >= FLOOR_Y:
		vertical_speed = 0.0
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#13263d"))
	draw_rect(Rect2(0, 300, 640, 60), Color("#4b6a49"))
	# Temporary red silhouette; final character art comes later.
	draw_rect(Rect2(hero_pos.x - 10, hero_pos.y - 45, 20, 45), Color("#b32835"))
	draw_circle(Vector2(hero_pos.x, hero_pos.y - 55), 11, Color("#b32835"))
	draw_line(Vector2(hero_pos.x - 5, hero_pos.y - 64), Vector2(hero_pos.x - 12, hero_pos.y - 78), Color("#e2c54a"), 2.0)
	draw_line(Vector2(hero_pos.x + 5, hero_pos.y - 64), Vector2(hero_pos.x + 12, hero_pos.y - 78), Color("#e2c54a"), 2.0)
	draw_rect(Rect2(15, 310, 90, 38), Color("#263c53"))
	draw_rect(Rect2(112, 310, 90, 38), Color("#263c53"))
	draw_rect(Rect2(535, 310, 90, 38), Color("#263c53"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 335), "ESQ", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(125, 335), "DIR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(545, 335), "PULO", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventScreenDrag:
		_handle_touch(event.position, true)

func _handle_touch(pos: Vector2, pressed: bool) -> void:
	var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * pos
	if screen_pos.y < 295.0:
		return
	if screen_pos.x < 108.0:
		move_axis = -1.0 if pressed else 0.0
	elif screen_pos.x < 208.0:
		move_axis = 1.0 if pressed else 0.0
	elif screen_pos.x > 525.0 and pressed:
		jump_requested = true
