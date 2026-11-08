extends Node2D

# Cenário de testes horizontal. Toda a arte oficial do Chapolin segue intacta.
const Stage = preload("res://scripts/stage_test.gd")
const SPEED := 190.0
const RUN_SPEED := 290.0
const RUN_DELAY := 0.48
const RUN_FPS := 11.8
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
var run_hold_time := 0.0
var run_direction := 0
var running := false
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
var run_texture: Texture2D
var jump_texture: Texture2D

func _ready() -> void:
	# Pixel-art filtering prevents neighboring atlas pixels bleeding into frames.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground_segments = Stage.ground()
	raised_platforms = Stage.platforms()
	crates = Stage.crates()

	# Mesmos sprites aprovados para idle, caminhada e salto.
	if ResourceLoader.exists("res://assets/chapolin_idle.png"):
		idle_texture = load("res://assets/chapolin_idle.png")
	if ResourceLoader.exists("res://assets/chapolin/walk.png"):
		walk_texture = load("res://assets/chapolin/walk.png")
	if ResourceLoader.exists("res://assets/chapolin/run.png"):
		run_texture = load("res://assets/chapolin/run.png")
	if ResourceLoader.exists("res://assets/chapolin/jump.png"):
		jump_texture = load("res://assets/chapolin/jump.png")
	queue_redraw()

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("ui_left", "ui_right")
	if absf(axis) < 0.1:
		axis = move_axis
	var direction := 0
	if absf(axis) > 0.1:
		direction = 1 if axis > 0.0 else -1
		facing = direction
	if direction == 0 or direction != run_direction or not grounded:
		run_hold_time = 0.0
	else:
		run_hold_time += delta
	run_direction = direction
	running = direction != 0 and grounded and run_hold_time >= RUN_DELAY and run_texture != null
	hero_pos.x = _move_x_with_crates(axis * (RUN_SPEED if running else SPEED) * delta)

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
	elif running:
		desired = "run"
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
	running = false
	run_hold_time = 0.0
	run_direction = 0
	jump_requested = false
	air_time = 0.0
	landing_timer = 0.0

func _draw() -> void:
	# Palco de televisao dos anos 70: os 'predios' sao paineis pintados.
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color("#161a29"))
	draw_rect(Rect2(0.0, 25.0, 640.0, 274.0), Color("#6e6a80"))
	draw_rect(Rect2(0.0, 156.0, 640.0, 144.0), Color("#807387"))
	draw_rect(Rect2(0.0, 276.0, 640.0, 84.0), Color("#342e3a"))

	draw_set_transform(Vector2(-camera_x * 0.15, 0.0), 0.0, Vector2.ONE)
	_draw_far_buildings()
	draw_set_transform(Vector2(-camera_x * 0.52, 0.0), 0.0, Vector2.ONE)
	_draw_near_buildings()

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_stage_lighting()

	draw_set_transform(Vector2(-camera_x, 0.0), 0.0, Vector2.ONE)
	_draw_decoration()
	for surface in ground_segments:
		_draw_stone(surface, true)
	for surface in raised_platforms:
		_draw_stone(surface, false)
	for block in crates:
		_draw_crate(block)

	# O Chapolin usa os sprites oficiais: nenhum pixel dele foi alterado.
	draw_set_transform(Vector2(roundf(hero_pos.x - camera_x), roundf(hero_pos.y)), 0.0, Vector2(float(facing), 1.0))
	_draw_chapolin()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_controls()

func _draw_far_buildings() -> void:
	# Fundo de pano pintado, preso por ganchos e emendas visiveis.
	draw_rect(Rect2(-120.0, 41.0, 3100.0, 253.0), Color("#777387"))
	for i in range(14):
		var x := float(i) * 230.0 - 105.0
		draw_rect(Rect2(x, 43.0, 224.0, 251.0), Color("#7b7a8c"))
		draw_rect(Rect2(x + 217.0, 43.0, 7.0, 251.0), Color("#56576b"))
		draw_line(Vector2(x, 43.0), Vector2(x + 217.0, 43.0), Color("#b7a5a0"), 3.0)
		draw_circle(Vector2(x + 8.0, 48.0), 2.0, Color("#4c414c"))
		draw_circle(Vector2(x + 210.0, 48.0), 2.0, Color("#4c414c"))
		var peaks := PackedVector2Array([
			Vector2(x - 5.0, 266.0),
			Vector2(x + 22.0, 201.0),
			Vector2(x + 47.0, 221.0),
			Vector2(x + 99.0, 141.0 + float(i % 3) * 13.0),
			Vector2(x + 141.0, 211.0),
			Vector2(x + 183.0, 180.0),
			Vector2(x + 224.0, 261.0)
		])
		draw_colored_polygon(peaks, Color("#4b536c"))
		draw_line(Vector2(x + 27.0, 206.0), Vector2(x + 99.0, 143.0 + float(i % 3) * 13.0), Color("#8d8c96"), 2.0)
		draw_rect(Rect2(x, 265.0, 224.0, 30.0), Color("#4a475a"))
		for j in range(5):
			var tree_x := x + float(j) * 47.0 + 10.0
			draw_colored_polygon(PackedVector2Array([
				Vector2(tree_x - 15.0, 267.0),
				Vector2(tree_x, 213.0 + float(j % 2) * 15.0),
				Vector2(tree_x + 15.0, 267.0)
			]), Color("#343e56"))
		# Cada emenda e um lembrete de que a paisagem e falsa.
		draw_line(Vector2(x + 217.0, 53.0), Vector2(x + 217.0, 288.0), Color("#c1ad9d"), 1.0)
	# Lua falsa pendurada por um fio de teatro.
	draw_line(Vector2(505.0, 0.0), Vector2(505.0, 81.0), Color("#24232c"), 2.0)
	draw_circle(Vector2(505.0, 96.0), 17.0, Color("#e2d0ab"))
	draw_circle(Vector2(500.0, 91.0), 3.0, Color("#b9a991"))
	draw_circle(Vector2(510.0, 103.0), 2.0, Color("#b9a991"))

func _draw_near_buildings() -> void:
	# Cidade inteira fabricada com paineis cenograficos, nao predios reais.
	for i in range(16):
		var x := float(i) * 208.0 - 36.0
		var top := 112.0 + float(i % 3) * 10.0
		var wall_color := Color("#b8896d") if i % 2 == 0 else Color("#a18b79")
		draw_rect(Rect2(x + 6.0, top + 6.0, 196.0, 176.0 - top), Color("#292b3c"))
		draw_rect(Rect2(x, top, 194.0, 292.0 - top), wall_color)
		draw_rect(Rect2(x - 4.0, top - 8.0, 201.0, 10.0), Color("#664b51"))
		draw_rect(Rect2(x + 3.0, top - 6.0, 192.0, 3.0), Color("#d8b89b"))
		draw_rect(Rect2(x + 9.0, top + 3.0, 3.0, 174.0 - top), Color("#e1b393"))
		# Tijolos 'pintados': marcas planas, sem juntas reais.
		for j in range(4):
			var brick_x := x + 19.0 + float(j) * 38.0
			draw_line(Vector2(brick_x, top + 24.0 + float(j % 2) * 12.0), Vector2(brick_x + 19.0, top + 24.0 + float(j % 2) * 12.0), Color("#945e5d"), 2.0)
			draw_line(Vector2(brick_x + 9.0, top + 24.0 + float(j % 2) * 12.0), Vector2(brick_x + 9.0, top + 32.0 + float(j % 2) * 12.0), Color("#945e5d"), 1.0)

		# Janela opaca pintada sobre o painel.
		var win_x := x + 31.0
		var win_y := top + 51.0
		draw_rect(Rect2(win_x - 5.0, win_y - 6.0, 63.0, 62.0), Color("#615062"))
		draw_rect(Rect2(win_x, win_y, 52.0, 50.0), Color("#333b57"))
		draw_rect(Rect2(win_x + 2.0, win_y + 2.0, 20.0, 23.0), Color("#c08b67"))
		draw_rect(Rect2(win_x + 26.0, win_y + 2.0, 24.0, 23.0), Color("#d4a277"))
		draw_rect(Rect2(win_x + 24.0, win_y, 4.0, 50.0), Color("#57414d"))
		draw_rect(Rect2(win_x, win_y + 25.0, 52.0, 4.0), Color("#57414d"))
		draw_rect(Rect2(win_x - 8.0, win_y + 49.0, 68.0, 6.0), Color("#d9b49a"))

		# Porta sem profundidade; moldura com madeira aparente na lateral.
		var door_x := x + 125.0
		draw_rect(Rect2(door_x - 5.0, 205.0, 58.0, 87.0), Color("#493b45"))
		draw_rect(Rect2(door_x, 211.0, 48.0, 81.0), Color("#65464a"))
		draw_rect(Rect2(door_x + 7.0, 220.0, 34.0, 64.0), Color("#88604f"))
		draw_circle(Vector2(door_x + 36.0, 259.0), 2.0, Color("#f0d8a7"))
		draw_rect(Rect2(x + 4.0, 288.0, 186.0, 5.0), Color("#715057"))

		# Por tras do painel: escoras e parafusos da cenografia.
		draw_line(Vector2(x + 192.0, top + 18.0), Vector2(x + 220.0, 298.0), Color("#50362f"), 5.0)
		draw_line(Vector2(x + 192.0, top + 18.0), Vector2(x + 192.0, 298.0), Color("#6a4a38"), 3.0)
		for bolt_y in [top + 10.0, 183.0, 280.0]:
			draw_circle(Vector2(x + 189.0, bolt_y), 2.0, Color("#ddc69c"))
		# Barra superior presa por dois cabos.
		draw_line(Vector2(x + 26.0, 20.0), Vector2(x + 26.0, top - 8.0), Color("#48404a"), 1.5)
		draw_line(Vector2(x + 163.0, 20.0), Vector2(x + 163.0, top - 8.0), Color("#48404a"), 1.5)

func _draw_stage_lighting() -> void:
	# O teto, os refletores e os feixes de luz ficam 'fora da ficcao'.
	for i in range(4):
		var lamp_x := 71.0 + float(i) * 166.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(lamp_x - 4.0, 37.0),
			Vector2(lamp_x + 4.0, 37.0),
			Vector2(lamp_x + 100.0, 300.0),
			Vector2(lamp_x - 95.0, 300.0)
		]), Color(1.0, 0.78, 0.52, 0.055))
	draw_rect(Rect2(0.0, 0.0, 640.0, 19.0), Color("#211c25"))
	draw_rect(Rect2(0.0, 19.0, 640.0, 5.0), Color("#55515c"))
	for x in [46.0, 212.0, 378.0, 544.0]:
		draw_line(Vector2(x, 23.0), Vector2(x, 36.0), Color("#2b2831"), 3.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 16.0, 38.0),
			Vector2(x + 16.0, 38.0),
			Vector2(x + 12.0, 54.0),
			Vector2(x - 12.0, 54.0)
		]), Color("#30303a"))
		draw_rect(Rect2(x - 10.0, 48.0, 20.0, 4.0), Color("#eac38b"))
	for i in range(9):
		var rig_x := float(i) * 85.0
		draw_line(Vector2(rig_x, 0.0), Vector2(rig_x + 25.0, 19.0), Color("#827786"), 1.0)
		draw_line(Vector2(rig_x + 25.0, 0.0), Vector2(rig_x, 19.0), Color("#827786"), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(242.0, 15.0), "ESTUDIO 1975", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#e2c8a0"))

func _draw_decoration() -> void:
	# Objetos fisicos decorativos; plataformas e caixas seguem as colisoes originais.
	for x in [126.0, 924.0, 1440.0, 1935.0, 2263.0]:
		draw_rect(Rect2(x, 207.0, 5.0, 93.0), Color("#52413c"))
		draw_rect(Rect2(x - 16.0, 201.0, 37.0, 8.0), Color("#aa865e"))
		draw_line(Vector2(x - 5.0, 209.0), Vector2(x + 11.0, 222.0), Color("#f1d6a7"), 2.0)
		draw_circle(Vector2(x + 3.0, 224.0), 10.0, Color("#d9a56c"))
		draw_circle(Vector2(x + 3.0, 224.0), 6.0, Color("#f6cf8c"))
	# Arbustos evidentemente recortados de papelao.
	for x in [98.0, 415.0, 879.0, 1332.0, 1690.0, 2180.0]:
		draw_rect(Rect2(x - 3.0, 282.0, 14.0, 18.0), Color("#694832"))
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 22.0, 280.0),
			Vector2(x - 6.0, 246.0),
			Vector2(x + 8.0, 266.0),
			Vector2(x + 19.0, 252.0),
			Vector2(x + 25.0, 280.0)
		]), Color("#637659"))
		draw_line(Vector2(x - 3.0, 282.0), Vector2(x + 2.0, 294.0), Color("#c09e77"), 2.0)
	# Plaquinha de bastidor.
	draw_rect(Rect2(80.0, 258.0, 91.0, 29.0), Color("#684b43"))
	draw_rect(Rect2(84.0, 261.0, 83.0, 22.0), Color("#d6b78a"))
	draw_string(ThemeDB.fallback_font, Vector2(90.0, 277.0), "NAO APOIAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#49382f"))
	draw_circle(Vector2(88.0, 265.0), 1.5, Color("#846245"))
	draw_circle(Vector2(164.0, 265.0), 1.5, Color("#846245"))
	# Montanha que encobre uma escada de servico (recurso cenografico visual).
	for x in [720.0, 1610.0]:
		draw_line(Vector2(x, 255.0), Vector2(x + 46.0, 298.0), Color("#705343"), 3.0)
		draw_line(Vector2(x + 46.0, 255.0), Vector2(x, 298.0), Color("#705343"), 3.0)
		draw_line(Vector2(x + 23.0, 255.0), Vector2(x + 23.0, 300.0), Color("#55413b"), 3.0)

func _draw_stone(surface: Rect2, is_floor: bool) -> void:
	# Piso e pranchas de madeira pintada, alinhados aos retangulos de colisao.
	if not is_floor:
		var leg_left := surface.position.x + 10.0
		var leg_right := surface.end.x - 10.0
		draw_line(Vector2(leg_left, surface.end.y), Vector2(leg_left, 300.0), Color("#6d4c38"), 5.0)
		draw_line(Vector2(leg_right, surface.end.y), Vector2(leg_right, 300.0), Color("#6d4c38"), 5.0)
		draw_line(Vector2(leg_left, surface.end.y), Vector2(leg_right, 296.0), Color("#98714e"), 2.0)
	draw_rect(surface, Color("#5c413a") if is_floor else Color("#785845"))
	draw_rect(Rect2(surface.position.x, surface.position.y, surface.size.x, 6.0), Color("#d9b68c"))
	draw_rect(Rect2(surface.position.x, surface.position.y + 6.0, surface.size.x, 7.0), Color("#9e765b"))
	var count := int(ceilf(surface.size.x / 30.0))
	for i in range(count):
		var plank_x := surface.position.x + float(i) * 30.0
		if plank_x > surface.end.x:
			break
		draw_line(Vector2(plank_x, surface.position.y + 6.0), Vector2(plank_x, minf(surface.end.y, surface.position.y + 14.0)), Color("#5c403a"), 2.0)
		if is_floor:
			var x2 := minf(plank_x + 25.0, surface.end.x)
			draw_line(Vector2(plank_x + 2.0, surface.position.y + 37.0), Vector2(x2, surface.position.y + 37.0), Color("#85624f"), 2.0)
			draw_line(Vector2(plank_x + 4.0, surface.position.y + 19.0), Vector2(x2 - 3.0, surface.position.y + 49.0), Color("#4a3b3d"), 1.0)
		else:
			draw_circle(Vector2(plank_x + 7.0, surface.position.y + 9.0), 1.3, Color("#edc9a0"))
	if not is_floor:
		draw_rect(Rect2(surface.position.x + 5.0, surface.end.y - 5.0, surface.size.x - 10.0, 4.0), Color("#453636"))

func _draw_crate(block: Rect2) -> void:
	# Caixa cenografica com travessas, pregos e etiqueta de inventario.
	draw_rect(block, Color("#5a3b31"))
	draw_rect(Rect2(block.position.x + 2.0, block.position.y + 2.0, block.size.x - 4.0, block.size.y - 4.0), Color("#a97851"))
	draw_rect(Rect2(block.position.x + 5.0, block.position.y + 5.0, block.size.x - 10.0, block.size.y - 10.0), Color("#c3976c"))
	draw_line(block.position + Vector2(5.0, 5.0), block.end - Vector2(5.0, 5.0), Color("#705040"), 3.0)
	draw_line(Vector2(block.end.x - 5.0, block.position.y + 5.0), Vector2(block.position.x + 5.0, block.end.y - 5.0), Color("#705040"), 3.0)
	draw_circle(block.position + Vector2(4.0, 4.0), 1.5, Color("#ead1a2"))
	draw_circle(block.end - Vector2(4.0, 4.0), 1.5, Color("#ead1a2"))

func _draw_chapolin() -> void:
	var sprite: Texture2D = idle_texture
	if current_animation == "walk" and walk_texture != null:
		sprite = walk_texture
	elif current_animation == "run" and run_texture != null:
		sprite = run_texture
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
		var fps := IDLE_FPS
		if current_animation == "walk" and walk_texture != null:
			fps = WALK_FPS
		elif current_animation == "run" and run_texture != null:
			fps = RUN_FPS
		frame = int(floor(animation_time * fps)) % 8
	var frame_size := Vector2(float(sprite.get_width()) / 8.0, float(sprite.get_height()))
	var region := Rect2(float(frame) * frame_size.x, 0.0, frame_size.x, frame_size.y)
	# Corrida tem atlas maior e 4px transparentes na base: respeita a altura oficial.
	var drawn_height := 112.0 if current_animation == "run" and run_texture != null else 101.0
	var drawn_width := frame_size.x * drawn_height / frame_size.y
	var dest := Rect2(-drawn_width / 2.0, -drawn_height, drawn_width, drawn_height)
	if current_animation == "run" and run_texture != null:
		dest.position.y += 4.0
	draw_texture_rect_region(sprite, dest, region, Color.WHITE, false, true)

func _draw_controls() -> void:
	# Mesmos botões e áreas de toque que já funcionam no Android.
	draw_rect(Rect2(15.0, 310.0, 90.0, 38.0), Color("#263c53"))
	draw_rect(Rect2(112.0, 310.0, 90.0, 38.0), Color("#263c53"))
	draw_rect(Rect2(535.0, 310.0, 90.0, 38.0), Color("#263c53"))
	draw_string(ThemeDB.fallback_font, Vector2(30.0, 335.0), "ESQ", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(125.0, 335.0), "DIR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(545.0, 335.0), "PULO", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(15.0, 26.0), "CIDADE DE PAPELAO  |  CENARIO DE TESTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f0cfaa"))

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
