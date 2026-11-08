extends Node2D

# Preserves the movement/jump prototype and replaces only the temporary drawing.
const SPEED := 190.0
const JUMP_SPEED := -350.0
const GRAVITY := 900.0
const FLOOR_Y := 300.0
const IDLE_FPS := 1000.0 / 230.0
const IDLE_FRAME_COUNT := 8
const FRAME_SIZE := Vector2(54.0, 101.0)

var hero_pos := Vector2(120.0, FLOOR_Y)
var vertical_speed := 0.0
var move_axis := 0.0
var jump_requested := false
var facing := 1.0
var idle_time := 0.0
var idle_frame := 0
var idle_texture: Texture2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	idle_texture = load("res://assets/chapolin_idle.png") as Texture2D
	queue_redraw()

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("ui_left", "ui_right")
	if absf(axis) < 0.1:
		axis = move_axis
	if axis > 0.1:
		facing = 1.0
	elif axis < -0.1:
		facing = -1.0
	hero_pos.x = clampf(hero_pos.x + axis * SPEED * delta, 27.0, 613.0)
	if (Input.is_action_just_pressed("ui_accept") or jump_requested) and hero_pos.y >= FLOOR_Y:
		vertical_speed = JUMP_SPEED
	jump_requested = false
	vertical_speed += GRAVITY * delta
	hero_pos.y = minf(hero_pos.y + vertical_speed * delta, FLOOR_Y)
	if hero_pos.y >= FLOOR_Y:
		vertical_speed = 0.0
	# Breathing and antenna motion use the eight approved GIF frames.
	if absf(axis) < 0.1 and hero_pos.y >= FLOOR_Y:
		idle_time += delta
		idle_frame = int(idle_time * IDLE_FPS) % IDLE_FRAME_COUNT
	else:
		idle_time = 0.0
		idle_frame = 0
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#13263d"))
	draw_rect(Rect2(0, 300, 640, 60), Color("#4b6a49"))
	if idle_texture != null:
		draw_set_transform(hero_pos, 0.0, Vector2(facing, 1.0))
		draw_texture_rect_region(
			idle_texture,
			Rect2(-FRAME_SIZE.x / 2.0, -FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y),
			Rect2(float(idle_frame) * FRAME_SIZE.x, 0.0, FRAME_SIZE.x, FRAME_SIZE.y)
		)
		draw_set_transform(Vector2.ZERO)
	# Keep the touchscreen controls from the already validated prototype.
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