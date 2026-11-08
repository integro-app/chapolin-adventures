extends Node2D

# Cenário de testes horizontal. Toda a arte oficial do Chapolin segue intacta.
const Stage = preload("res://scripts/stage_test.gd")
const SPEED := 190.0
const JUMP_SPEED := -350.0
const GRAVITY := 900.0
const IDLE_FPS := 4.35
const WALK_FPS := 8.3
const SCREEN_WIDTH := 640.0
const HERO_HALF_WIDTH := 11.0

var hero_pos := Vector2(120.0, 300.0)
var vertical_speed := 0.0
var grounded := true
var move_axis := 0.0
var jump_requested := false
var facing := 1
var animation_time := 0.0
var current_animation := "idle"
var air_time := 0.0
var landing_timer := 0.0
var camera_x := 0.0

var ground_segments: Array[Rect2] = []
var raised_platforms: Array[Rect2] = []
var crates: Array[Rect2] = []
var idle_texture: Texture2D
var walk_texture: Texture2D
var jump_texture: Texture2D

func _ready() -> void:
	ground_segments = Stage.ground()
	raised_platforms = Stage.platforms()
	crates = Stage.crates()

	# Mesmos sprites aprovados para idle, caminhada e salto.
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
	if absf(axis) > 0.1:
		facing = 1 if axis > 0.0 else -1
	hero_pos.x = _move_x_with_crates(axis * SPEED * delta)

	var was_grounded := grounded
	var is_jumping := (Input.is_action_just_pressed("ui_accept") or jump_requested) and grounded
	jump_requested = false
	if is_jumping:
		grounded = false
		vertical_speed = JUMP_SPEED
		air_time = 0.0
		landing_timer = 0.0
	elif grounded and not _has_support(hero_pos.x, hero_pos.y):
		# Andou além da borda de uma plataforma: começa a cair.
		grounded = false
		vertical_speed = 0.0

	if not grounded:
		var last_y := hero_pos.y
		vertical_speed += GRAVITY * delta
		var next_y := last_y + vertical_speed * delta
		if vertical_speed >= 0.0:
			var top_y := _find_landing_surface(last_y, next_y, hero_pos.x)
			if top_y < INF:
				hero_pos.y = top_y
				vertical_speed = 0.0
				grounded = true
			else:
				hero_pos.y = next_y
		else:
			hero_pos.y = next_y

	if grounded:
		if not was_grounded:
			landing_timer = 0.16
		else:
			landing_timer = maxf(0.0, landing_timer - delta)
	else:
		air_time += delta

	# Quedas nos vãos retornam ao começo do trecho de testes.
	if hero_pos.y > 435.0:
		_respawn()

	var desired := "idle"
	if not grounded and jump_texture != null:
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

	# A câmera acompanha suavemente, respeitando as bordas do mundo.
	var camera_target := clampf(hero_pos.x - 215.0, 0.0, Stage.WORLD_WIDTH - SCREEN_WIDTH)
	camera_x = lerpf(camera_x, camera_target, minf(1.0, delta * 6.5))
	queue_redraw()

func _has_support(x: float, y: float) -> bool:
	for surface in ground_segments:
		if _on_surface(x, y, surface):
			return true
	for surface in raised_platforms:
		if _on_surface(x, y, surface):
			return true
	for surface in crates:
		if _on_surface(x, y, surface):
			return true
	return false

func _on_surface(x: float, y: float, surface: Rect2) -> bool:
	return absf(y - surface.position.y) <= 1.0 and x + 6.0 > surface.position.x and x - 6.0 < surface.end.x

func _find_landing_surface(from_y: float, to_y: float, x: float) -> float:
	var landing := INF
	for surface in ground_segments:
		if _crosses_top(from_y, to_y, x, surface):
			landing = minf(landing, surface.position.y)
	for surface in raised_platforms:
		if _crosses_top(from_y, to_y, x, surface):
			landing = minf(landing, surface.position.y)
	for surface in crates:
		if _crosses_top(from_y, to_y, x, surface):
			landing = minf(landing, surface.position.y)
	return landing

func _crosses_top(from_y: float, to_y: float, x: float, surface: Rect2) -> bool:
	return from_y <= surface.position.y and to_y >= surface.position.y and x + 6.0 > surface.position.x and x - 6.0 < surface.end.x

func _move_x_with_crates(distance: float) -> float:
	var next_x := clampf(hero_pos.x + distance, HERO_HALF_WIDTH, Stage.WORLD_WIDTH - HERO_HALF_WIDTH)
	for block in crates:
		# Caixas são sólidas nas laterais e podem ser usadas como plataformas.
		if hero_pos.y <= block.position.y + 4.0 or hero_pos.y - 75.0 >= block.end.y:
			continue
		if distance > 0.0 and hero_pos.x + HERO_HALF_WIDTH <= block.position.x and next_x + HERO_HALF_WIDTH > block.position.x:
			next_x = block.position.x - HERO_HALF_WIDTH
		elif distance < 0.0 and hero_pos.x - HERO_HALF_WIDTH >= block.end.x and next_x - HERO_HALF_WIDTH < block.end.x:
			next_x = block.end.x + HERO_HALF_WIDTH
	return next_x

func _respawn() -> void:
	hero_pos = Stage.RESPAWN
	vertical_speed = 0.0
	grounded = true
	move_axis = 0.0
	jump_requested = false
	air_time = 0.0
	landing_timer = 0.0

func _draw() -> void:
	# Camadas independentes produzem profundidade sem modificar o personagem.
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color("#142439"))
	draw_rect(Rect2(0.0, 0.0, 640.0, 112.0), Color("#101b30"))
	draw_circle(Vector2(546.0, 66.0), 20.0, Color("#dec7a0"))

	draw_set_transform(Vector2(-camera_x * 0.18, 0.0), 0.0, Vector2.ONE)
	_draw_far_buildings()
	draw_set_transform(Vector2(-camera_x * 0.55, 0.0), 0.0, Vector2.ONE)
	_draw_near_buildings()

	draw_set_transform(Vector2(-camera_x, 0.0), 0.0, Vector2.ONE)
	_draw_decoration()
	for surface in ground_segments:
		_draw_stone(surface, true)
	for surface in raised_platforms:
		_draw_stone(surface, false)
	for block in crates:
		_draw_crate(block)

	# A posição e as dimensões dos sprites oficiais são preservadas.
	draw_set_transform(hero_pos - Vector2(camera_x, 0.0), 0.0, Vector2(float(facing), 1.0))
	_draw_chapolin()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_controls()

func _draw_far_buildings() -> void:
	for i in range(26):
		var x := float(i) * 127.0 - 60.0
		var height := 113.0 + float(i % 4) * 17.0
		draw_rect(Rect2(x, 292.0 - height, 135.0, height), Color("#1d2a40"))
		draw_rect(Rect2(x + 15.0, 268.0 - height, 19.0, 24.0), Color("#1d2a40"))
		for j in range(2):
			draw_rect(Rect2(x + 24.0 + float(j) * 59.0, 248.0 - height, 18.0, 29.0), Color("#334059"))

func _draw_near_buildings() -> void:
	for i in range(17):
		var x := float(i) * 187.0 - 33.0
		var top := 106.0 + float(i % 3) * 13.0
		draw_rect(Rect2(x, top, 177.0, 195.0 - top), Color("#35405a"))
		draw_rect(Rect2(x - 3.0, top - 5.0, 183.0, 8.0), Color("#6d5660"))
		draw_rect(Rect2(x + 9.0, top + 10.0, 4.0, 145.0), Color("#42435b"))
		for j in range(2):
			var wx := x + 32.0 + float(j) * 77.0
			var wy := top + 33.0
			draw_rect(Rect2(wx - 4.0, wy - 4.0, 43.0, 54.0), Color("#252b43"))
			draw_rect(Rect2(wx, wy, 35.0, 45.0), Color("#a87957"))
			draw_rect(Rect2(wx + 17.0, wy, 3.0, 45.0), Color("#473b47"))
			draw_rect(Rect2(wx, wy + 20.0, 35.0, 3.0), Color("#473b47"))
		draw_rect(Rect2(x + 8.0, 286.0, 160.0, 5.0), Color("#555066"))

func _draw_decoration() -> void:
	for x in [145.0, 935.0, 1450.0, 1930.0, 2260.0]:
		draw_rect(Rect2(x, 209.0, 5.0, 91.0), Color("#262f3b"))
		draw_rect(Rect2(x - 16.0, 205.0, 35.0, 5.0), Color("#262f3b"))
		draw_circle(Vector2(x + 4.0, 219.0), 11.0, Color("#d4a16f"))
		draw_circle(Vector2(x + 4.0, 219.0), 6.0, Color("#f0ca86"))
	for x in [93.0, 410.0, 886.0, 1328.0, 1692.0, 2190.0]:
		draw_rect(Rect2(x, 280.0, 5.0, 20.0), Color("#274b44"))
		draw_line(Vector2(x + 2.0, 286.0), Vector2(x - 13.0, 275.0), Color("#55735b"), 3.0)
		draw_line(Vector2(x + 3.0, 292.0), Vector2(x + 14.0, 278.0), Color("#55735b"), 3.0)
	draw_rect(Rect2(110.0, 264.0, 76.0, 26.0), Color("#72514b"))
	draw_rect(Rect2(115.0, 270.0, 66.0, 17.0), Color("#473a41"))
	draw_string(ThemeDB.fallback_font, Vector2(121.0, 283.0), "TESTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f1d1a5"))

func _draw_stone(surface: Rect2, is_floor: bool) -> void:
	draw_rect(surface, Color("#293148"))
	draw_rect(Rect2(surface.position.x, surface.position.y, surface.size.x, 7.0), Color("#ae8a74"))
	draw_rect(Rect2(surface.position.x, surface.position.y + 7.0, surface.size.x, 7.0), Color("#594957"))
	var count := int(ceilf(surface.size.x / 32.0))
	for i in range(count):
		var x := surface.position.x + float(i) * 32.0
		if x > surface.end.x:
			break
		draw_line(Vector2(x, surface.position.y + 7.0), Vector2(x, minf(surface.end.y, surface.position.y + 14.0)), Color("#302e41"), 2.0)
	if is_floor:
		for i in range(count):
			var x := surface.position.x + float(i) * 32.0
			draw_line(Vector2(x, surface.position.y + 29.0), Vector2(minf(x + 30.0, surface.end.x), surface.position.y + 29.0), Color("#455068"), 2.0)
	else:
		draw_rect(Rect2(surface.position.x + 6.0, surface.end.y - 4.0, surface.size.x - 12.0, 4.0), Color("#1b2538"))

func _draw_crate(block: Rect2) -> void:
	draw_rect(block, Color("#916140"))
	draw_rect(Rect2(block.position.x + 3.0, block.position.y + 3.0, block.size.x - 6.0, block.size.y - 6.0), Color("#bd8757"))
	draw_line(block.position + Vector2(4.0, 4.0), block.end - Vector2(4.0, 4.0), Color("#67402e"), 3.0)
	draw_line(Vector2(block.end.x - 4.0, block.position.y + 4.0), Vector2(block.position.x + 4.0, block.end.y - 4.0), Color("#67402e"), 3.0)

func _draw_chapolin() -> void:
	var sprite: Texture2D = idle_texture
	if current_animation == "walk" and walk_texture != null:
		sprite = walk_texture
	elif (current_animation == "jump" or current_animation == "land") and jump_texture != null:
		sprite = jump_texture

	if sprite == null:
		# Apenas fallback: a arte oficial não foi substituída.
		draw_rect(Rect2(-10.0, -45.0, 20.0, 45.0), Color("#b32835"))
		draw_circle(Vector2.ZERO + Vector2(0.0, -55.0), 11.0, Color("#b32835"))
		return

	var frame: int = 0
	if current_animation == "jump" and jump_texture != null:
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
	draw_texture_rect_region(sprite, dest, region)

func _draw_controls() -> void:
	# Mesmos botões e áreas de toque que já funcionam no Android.
	draw_rect(Rect2(15.0, 310.0, 90.0, 38.0), Color("#263c53"))
	draw_rect(Rect2(112.0, 310.0, 90.0, 38.0), Color("#263c53"))
	draw_rect(Rect2(535.0, 310.0, 90.0, 38.0), Color("#263c53"))
	draw_string(ThemeDB.fallback_font, Vector2(30.0, 335.0), "ESQ", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(125.0, 335.0), "DIR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(545.0, 335.0), "PULO", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(15.0, 26.0), "CENARIO DE TESTES", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f0cfaa"))

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
