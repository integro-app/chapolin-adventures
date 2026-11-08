extends Node2D

const SPEED := 190.0
const JUMP_SPEED := -350.0
const GRAVITY := 900.0
const FLOOR_Y := 300.0
const IDLE_FPS := 4.35
const WALK_FPS := 8.3

var hero_pos := Vector2(120.0, FLOOR_Y)
var vertical_speed := 0.0
var move_axis := 0.0
var jump_requested := false
var facing := 1
var animation_time := 0.0
var current_animation := "idle"
var idle_texture: Texture2D
var walk_texture: Texture2D
var jump_texture: Texture2D
var air_time := 0.0
var landing_timer := 0.0

func _ready() -> void:
	# Each texture contains eight transparent frames. Size comes from its file.
	if ResourceLoader.exists("res://assets/chapolin_idle.png"):
		idle_texture = load("res://assets/chapolin_idle.png")
	if ResourceLoader.exists("res://assets/chapolin/walk.png"):
		walk_texture = load("res://assets/chapolin/walk.png")
	if ResourceLoader.exists("res://assets/chapolin/jump.png"):
		jump_texture = load("res://assets/chapolin/jump.png")
	queue_redraw()

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("ui_left", "ui_right")
	if absf(axis) < 0.1:
		axis = move_axis
	if axis != 0.0:
		facing = 1 if axis > 0.0 else -1
	hero_pos.x = clampf(hero_pos.x + axis * SPEED * delta, 24.0, 616.0)

	var was_airborne := hero_pos.y < FLOOR_Y
	if (Input.is_action_just_pressed("ui_accept") or jump_requested) and not was_airborne:
		vertical_speed = JUMP_SPEED
		air_time = 0.0
		landing_timer = 0.0
	jump_requested = false

	vertical_speed += GRAVITY * delta
	hero_pos.y = minf(hero_pos.y + vertical_speed * delta, FLOOR_Y)
	var is_airborne := hero_pos.y < FLOOR_Y
	if is_airborne:
		air_time += delta
	else:
		vertical_speed = 0.0
		if was_airborne:
			landing_timer = 0.16
		else:
			landing_timer = maxf(0.0, landing_timer - delta)

	var desired := "idle"
	if is_airborne and jump_texture != null:
		desired = "jump"
	elif landing_timer > 0.0 and jump_texture != null:
		desired = "land"
	elif absf(axis) > 0.1:
		desired = "walk"

	if desired != current_animation:
		current_animation = desired
		animation_time = 0.0
	else:
		animation_time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#13263d"))
	draw_rect(Rect2(0, 300, 640, 60), Color("#4b6a49"))
	var sprite: Texture2D = idle_texture
	if current_animation == "walk" and walk_texture != null:
		sprite = walk_texture
	elif (current_animation == "jump" or current_animation == "land") and jump_texture != null:
		sprite = jump_texture
	if sprite == null:
		# Safe fallback until the approved sprite assets are available.
		draw_rect(Rect2(hero_pos.x - 10, hero_pos.y - 45, 20, 45), Color("#b32835"))
		draw_circle(Vector2(hero_pos.x, hero_pos.y - 55), 11, Color("#b32835"))
	else:
		var frame: int = 0
		if current_animation == "jump" and jump_texture != null:
			# Play jump poses against the actual vertical speed, never as a repeating loop.
			if air_time < 0.07:
				frame = 1
			elif vertical_speed < -180.0:
				frame = 2
			elif vertical_speed < -50.0:
				frame = 3
			elif vertical_speed < 80.0:
				frame = 4
			else:
				frame = 5
		elif current_animation == "land" and jump_texture != null:
			frame = 6 if landing_timer > 0.08 else 7
		else:
			var fps := WALK_FPS if current_animation == "walk" and walk_texture != null else IDLE_FPS
			frame = int(floor(animation_time * fps)) % 8
		var frame_size := Vector2(float(sprite.get_width()) / 8.0, float(sprite.get_height()))
		var region := Rect2(float(frame) * frame_size.x, 0.0, frame_size.x, frame_size.y)
		var drawn_height := 101.0
		var drawn_width := frame_size.x * drawn_height / frame_size.y
		var dest := Rect2(-drawn_width / 2.0, -drawn_height, drawn_width, drawn_height)
		draw_set_transform(hero_pos, 0.0, Vector2(float(facing), 1.0))
		draw_texture_rect_region(sprite, dest, region)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Preserve mobile controls and positions.
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
