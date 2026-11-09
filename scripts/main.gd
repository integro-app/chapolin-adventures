extends Node2D

# Cenário de testes horizontal. Toda a arte oficial do Chapolin segue intacta.
const Stage = preload("res://scripts/stage_test.gd")
const Feedback = preload("res://scripts/game_feedback.gd")
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
const STAND_HEIGHT := 101.0
const CROUCH_HEIGHT := 83.0
const CROUCH_SPEED := 92.0
const CLIMB_SPEED := 90.0
const JOYSTICK_RADIUS := 51.0
const JOYSTICK_DEADZONE := 13.0
const MOUSE_POINTER_ID := -2
const ROPE_FOOT_OFFSET := 82.0
const ROPE_GRAB_DISTANCE := 18.0
const ROPE_MIN_GRIP := 12.0
const ROPE_CLIMB_SPEED := 95.0
const ROPE_SWING_ACCEL := 8.4
const ROPE_MAX_ANGLE := 0.78
const ROPE_LAUNCH_MULTIPLIER := 1.55
const ROPE_LAUNCH_MAX_SPEED := 460.0
const ROPE_LAUNCH_UPWARD_BOOST := 185.0
const ROPE_AIR_MOMENTUM_DRAG := 45.0
const ROPE_AIR_STEERING := 85.0
const ENEMY_SPEED := 46.0
const ENEMY_HALF_WIDTH := 13.0
const ENEMY_HEIGHT := 27.0
const ENEMY_STOMP_BOUNCE := -245.0
const OBSTACLE_RADIUS := 14.0
const DAMAGE_GRACE := 1.5
const MAX_HEALTH := 3
const MAX_LIVES := 3
const DAMAGE_KNOCKBACK := 185.0
const DAMAGE_RECOIL_UP := -160.0
const HAMMER_REACH := 76.0
const HAMMER_COOLDOWN := 0.48
const HAMMER_SWING_DURATION := 0.23
const HORN_RANGE := 210.0
const HORN_STUN_SECONDS := 3.5
const HORN_COOLDOWN := 0.6
const HORN_MAX_CHARGES := 3
const HORN_EFFECT_DURATION := 0.32
const NANO_SCALE := 0.34
const NANO_DURATION := 9.0
const NANO_MAX_CHARGES := 3
const NANO_SPEED := 155.0
const NANO_TUNNEL_MARGIN := 0.5
const SAVE_PATH := "user://chapolin_save_v1.json"
const SAVE_VERSION := 1
const AUTOSAVE_INTERVAL := 0.8
const LEDGE_HANG_DEPTH := 74.0
const LEDGE_HANG_SIDE_OFFSET := 14.0
const LEDGE_GRAB_X_TOLERANCE := 14.0
const LEDGE_GRAB_Y_MIN := 2.0
const LEDGE_GRAB_Y_MAX := 83.0
const LEDGE_CLIMB_SECONDS := 0.30
const LEDGE_RELEASE_DELAY := 0.55
const LEVER_REACH := 43.0
const LEVER_HEIGHT_REACH := 58.0
const SECRET_LIFE_LIMIT := 5
const BREAK_EFFECT_SECONDS := 0.42
const STORY_SKIP_RECT := Rect2(63.0, 278.0, 157.0, 48.0)
const STORY_NEXT_RECT := Rect2(403.0, 278.0, 169.0, 48.0)
const TITLE_PLAY_RECT := Rect2(60.0, 245.0, 211.0, 54.0)
const TITLE_NEW_RECT := Rect2(286.0, 245.0, 211.0, 54.0)
const STAGE_BANNER_DURATION := 3.4
const HUD_PAUSE_RECT := Rect2(572.0, 4.0, 62.0, 48.0)
# HUD v3 — layout da arte aprovada, em coordenadas 640x360.
const HUD_V3_PAUSE_RECT := Rect2(600.0, 0.0, 40.0, 29.0)
const HUD_V3_HAMMER_RECT := Rect2(329.0, 299.0, 51.0, 61.0)
const HUD_V3_HORN_RECT := Rect2(386.0, 299.0, 53.0, 61.0)
const HUD_V3_NANO_RECT := Rect2(441.0, 233.0, 50.0, 53.0)
const HUD_V3_USE_RECT := Rect2(476.0, 288.0, 62.0, 71.0)
const HUD_V3_JUMP_RECT := Rect2(547.0, 283.0, 87.0, 77.0)
const HUD_V3_RUN_RECT := Rect2(554.0, 206.0, 82.0, 75.0)
const SOUND_TOGGLE_RECT := Rect2(420.0, 65.0, 113.0, 36.0)

var hero_pos := Vector2(120.0, 300.0)
var vertical_speed := 0.0
var grounded := true
var move_axis := 0.0
var run_hold_time := 0.0
var run_direction := 0
var running := false
var climb_up_held := false
var climb_down_held := false
var climbing := false
var swinging := false
var rope_anchor := Vector2.ZERO
var rope_length := 0.0
var rope_grip_distance := 0.0
var rope_blocked_anchor_x := -1.0
var rope_angle := 0.0
var rope_angular_velocity := 0.0
var rope_release_vx := 0.0
var rope_regrab_delay := 0.0
var climb_ladder := Rect2()
var ledge_hanging := false
var ledge_climbing := false
var ledge_edge := Vector2.ZERO
var ledge_grab_points: Array[Vector3] = []
var ledge_side := 1
var ledge_cooldown := 0.0
var ledge_blocked_edge := Vector2(-1000.0, -1000.0)
var ledge_climb_elapsed := 0.0
var ledge_climb_from := Vector2.ZERO
var ledge_climb_to := Vector2.ZERO
var crouch_held := false
var is_crouching := false
var joystick_touch_id := -1
var run_touch_id := -1
var joystick_origin := Vector2.ZERO
var joystick_offset := Vector2.ZERO
var jump_requested := false
var facing := 1
var animation_time := 0.0
var current_animation := "idle"
var air_time := 0.0
var landing_timer := 0.0
var camera_x := 0.0

var ground_segments: Array[Rect2] = []
var raised_platforms: Array[Rect2] = []
var moving_platform_specs: Array[Dictionary] = []
var moving_platform_rects: Array[Rect2] = []
var moving_platform_directions: Array[float] = []
var crates: Array[Rect2] = []
var pressure_plates: Array[Rect2] = []
var puzzle_gates: Array[Rect2] = []
var puzzle_gate_open := false
var lever_points: Array[Vector3] = []
var lever_states: Array[bool] = []
var lever_gate: Rect2 = Rect2()
var fragile_walls: Array[Rect2] = []
var fragile_broken: Array[bool] = []
var secret_rewards: Array[Vector2] = []
var secret_collected: Array[bool] = []
var secret_count := 0
var break_effects: Array[float] = []
var medals: Array[Vector2] = []
var medal_collected: Array[bool] = []
var medal_count := 0
var respawn_point := Stage.RESPAWN
var checkpoint_active := false
var stage_complete := false
var finish_medals := 0
var rescue_complete := false
var intro_seen := false
var checkpoint_story_seen := false
var story_active := false
var story_scene_id := ""
var story_step := 0
var story_pages: Array[Dictionary] = []
var title_active := true
var title_has_save := false
var title_clock := 0.0
var stage_banner_timer := 0.0
var scene_ambience_clock := 0.0
var feedback = Feedback.new()
var enemy_patrols: Array[Vector3] = []
var enemy_positions: Array[Vector2] = []
var enemy_directions: Array[float] = []
var enemy_active: Array[bool] = []
var moving_obstacles: Array[Vector3] = []
var hazard_clock := 0.0
var hurt_grace := 0.0
var health := MAX_HEALTH
var lives := MAX_LIVES
var game_over := false
var damage_knockback_vx := 0.0
var combat_pickups: Array[Vector3] = []
var pickup_collected: Array[bool] = []
var hammer_unlocked := false
var horn_unlocked := false
var horn_charges := 0
var hammer_cooldown := 0.0
var hammer_swing_time := 0.0
var horn_cooldown := 0.0
var horn_effect_time := 0.0
var horn_blast_origin := Vector2.ZERO
var horn_blast_facing := 1
var enemy_stun: Array[float] = []
var nano_pickups: Array[Vector2] = []
var nano_pickup_collected: Array[bool] = []
var nano_tunnels: Array[Rect2] = []
var nano_unlocked := false
var nano_charges := 0
var nano_remaining := 0.0
var pause_menu_open := false
var save_dirty := false
var save_delay := 0.0
var save_notice_time := 0.0
var installed_build := "SEM MARCADOR"
var sound_enabled := true
var sfx_players: Dictionary = {}
var low_beams: Array[Rect2] = []
var ladders: Array[Rect2] = []
var ropes: Array[Vector3] = []
var sky_panorama: Texture2D
var city_facades: Texture2D
var city_bg_art: Texture2D
var city_mid_art: Texture2D
var city_set_art: Texture2D
var city_lights_art: Texture2D
var hud_v3_bar: Texture2D
var hud_v3_icons: Texture2D
var hud_v3_controls: Texture2D
var hud_icons: Texture2D
var idle_texture: Texture2D
var walk_texture: Texture2D
var run_texture: Texture2D
var jump_texture: Texture2D

func _ready() -> void:
	# A revisao mostrada no menu identifica QUAL copia foi aberta no Godot.
	# O sincronizador grava o arquivo na pasta do projeto depois do download.
	var build_file: FileAccess = FileAccess.open("res://CHAPOLIN_VERSAO.txt", FileAccess.READ)
	if build_file != null:
		for build_line in build_file.get_as_text().split("\n"):
			if build_line.begins_with("Commit: "):
				installed_build = build_line.substr(8, 12)
				break
	# Pixel-art filtering prevents neighboring atlas pixels bleeding into frames.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground_segments = Stage.ground()
	raised_platforms = Stage.platforms()
	moving_platform_specs = Stage.moving_platforms()
	_setup_moving_platforms()
	ledge_grab_points = Stage.ledge_grab_points()
	crates = Stage.crates()
	pressure_plates = Stage.pressure_plates()
	puzzle_gates = Stage.puzzle_gates()
	lever_points = Stage.levers()
	lever_gate = Stage.lever_gate()
	for _lever in lever_points:
		lever_states.append(false)
	fragile_walls = Stage.fragile_walls()
	secret_rewards = Stage.secret_rewards()
	for _panel in fragile_walls:
		fragile_broken.append(false)
		break_effects.append(0.0)
	for _reward in secret_rewards:
		secret_collected.append(false)
	medals = Stage.medals()
	for _medal in medals:
		medal_collected.append(false)
	low_beams = Stage.low_beams()
	ladders = Stage.ladders()
	ropes = Stage.ropes()
	enemy_patrols = Stage.enemy_patrols()
	moving_obstacles = Stage.moving_obstacles()
	combat_pickups = Stage.combat_pickups()
	for _pickup in combat_pickups:
		pickup_collected.append(false)
	nano_pickups = Stage.nano_pickups()
	nano_tunnels = Stage.nano_tunnels()
	for _nano_pickup in nano_pickups:
		nano_pickup_collected.append(false)
	_reset_enemies()

	# Os quatro PNGs correspondem as imagens aprovadas. A cenografia
	# anterior permanece como fallback para problemas de importacao.
	if ResourceLoader.exists("res://assets/stage/cidade_bg.png"):
		city_bg_art = load("res://assets/stage/cidade_bg.png")
	if ResourceLoader.exists("res://assets/stage/cidade_mid.png"):
		city_mid_art = load("res://assets/stage/cidade_mid.png")
	if ResourceLoader.exists("res://assets/stage/cidade_set.png"):
		city_set_art = load("res://assets/stage/cidade_set.png")
	if ResourceLoader.exists("res://assets/stage/cidade_lights.png"):
		city_lights_art = load("res://assets/stage/cidade_lights.png")
	if ResourceLoader.exists("res://assets/stage/cidade_papelao_sky.svg"):
		sky_panorama = load("res://assets/stage/cidade_papelao_sky.svg")
	if ResourceLoader.exists("res://assets/stage/cidade_papelao_facades.svg"):
		city_facades = load("res://assets/stage/cidade_papelao_facades.svg")

	# HUD comercial v3: arte aprovada, atlases independentes e otimizados.
	if ResourceLoader.exists("res://assets/hud/v3/hud_bar.webp"):
		hud_v3_bar = load("res://assets/hud/v3/hud_bar.webp")
	if ResourceLoader.exists("res://assets/hud/v3/hud_icons.webp"):
		hud_v3_icons = load("res://assets/hud/v3/hud_icons.webp")
	if ResourceLoader.exists("res://assets/hud/v3/hud_controls.webp"):
		hud_v3_controls = load("res://assets/hud/v3/hud_controls.webp")
	# Fallback v2 caso algum atlas ainda nao tenha importado no Godot.
	if ResourceLoader.exists("res://assets/hud/icons_v2.svg"):
		hud_icons = load("res://assets/hud/icons_v2.svg")

	# Mesmos sprites aprovados para idle, caminhada e salto.
	if ResourceLoader.exists("res://assets/chapolin_idle.png"):
		idle_texture = load("res://assets/chapolin_idle.png")
	if ResourceLoader.exists("res://assets/chapolin/walk.png"):
		walk_texture = load("res://assets/chapolin/walk.png")
	if ResourceLoader.exists("res://assets/chapolin/run.png"):
		run_texture = load("res://assets/chapolin/run.png")
	if ResourceLoader.exists("res://assets/chapolin/jump.png"):
		jump_texture = load("res://assets/chapolin/jump.png")
	_setup_sfx()
	# A tela inicial deixa o jogador escolher continuar ou iniciar a aventura.
	title_has_save = FileAccess.file_exists(SAVE_PATH)
	_load_game()
	title_active = true
	queue_redraw()

func _physics_process(delta: float) -> void:
	if title_active:
		title_clock += delta
		queue_redraw()
		return
	if save_dirty:
		save_delay -= delta
		if save_delay <= 0.0:
			_save_game()
	save_notice_time = maxf(0.0, save_notice_time - delta)
	if story_active:
		if Input.is_action_just_pressed("ui_accept"):
			_advance_story()
		jump_requested = false
		queue_redraw()
		return
	if pause_menu_open:
		queue_redraw()
		return
	feedback.tick(delta)
	scene_ambience_clock += delta
	stage_banner_timer = maxf(0.0, stage_banner_timer - delta)
	if stage_complete or game_over:
		if Input.is_action_just_pressed("ui_accept") or jump_requested:
			_restart_stage()
		jump_requested = false
		queue_redraw()
		return
	var previous_foot_y: float = hero_pos.y
	for i in range(break_effects.size()):
		break_effects[i] = maxf(0.0, break_effects[i] - delta)
	_update_nano_timer(delta)
	hammer_cooldown = maxf(0.0, hammer_cooldown - delta)
	hammer_swing_time = maxf(0.0, hammer_swing_time - delta)
	horn_cooldown = maxf(0.0, horn_cooldown - delta)
	horn_effect_time = maxf(0.0, horn_effect_time - delta)
	hurt_grace = maxf(0.0, hurt_grace - delta)
	hazard_clock += delta
	_advance_moving_platforms(delta)
	_update_enemy_patrols(delta)
	rope_regrab_delay = maxf(0.0, rope_regrab_delay - delta)
	ledge_cooldown = maxf(0.0, ledge_cooldown - delta)
	# Depois de soltar, so libera a mesma borda quando o heroi se afasta.
	if ledge_blocked_edge.x > -900.0:
		if grounded or absf(hero_pos.x - ledge_blocked_edge.x) > LEDGE_GRAB_X_TOLERANCE + LEDGE_HANG_SIDE_OFFSET + 12.0 or hero_pos.y > ledge_blocked_edge.y + LEDGE_HANG_DEPTH + 35.0:
			ledge_blocked_edge = Vector2(-1000.0, -1000.0)
	if ledge_hanging or ledge_climbing:
		_handle_ledge(delta)
		if not _check_threat_collisions(previous_foot_y):
			_update_level_progress()
		_update_camera(delta)
		queue_redraw()
		return
	if _handle_rope(delta):
		if not _check_threat_collisions(previous_foot_y):
			_update_level_progress()
		_update_camera(delta)
		queue_redraw()
		return
	if _handle_ladder(delta):
		if not _check_threat_collisions(previous_foot_y):
			_update_level_progress()
		_update_camera(delta)
		queue_redraw()
		return
	var axis := Input.get_axis("ui_left", "ui_right")
	if absf(axis) < 0.1:
		axis = move_axis
	var direction := 0
	if absf(axis) > 0.1:
		direction = 1 if axis > 0.0 else -1
		facing = direction
	# Agachamento continua normal; a Nanicolina substitui a altura de colisao.
	var wants_crouch := crouch_held or (Input.is_action_pressed("ui_down") and _ladder_near(hero_pos.x, hero_pos.y).size.x == 0.0)
	is_crouching = grounded and not _nano_active() and (wants_crouch or _under_low_beam(hero_pos.x, hero_pos.y))
	if direction == 0 or direction != run_direction or not grounded or is_crouching:
		run_hold_time = 0.0
	else:
		run_hold_time += delta
	run_direction = direction
	running = direction != 0 and grounded and not is_crouching and (run_hold_time >= RUN_DELAY or run_touch_id != -1) and run_texture != null
	var move_speed := NANO_SPEED if _nano_active() else (CROUCH_SPEED if is_crouching else (RUN_SPEED if running else SPEED))
	var travel := axis * move_speed * delta
	if not grounded and absf(rope_release_vx) > 0.1:
		# Preserva a velocidade do pendulo depois do salto; o joystick so faz
		# uma correcao leve na trajetoria, em vez de apagar o impulso.
		travel = (rope_release_vx + axis * ROPE_AIR_STEERING) * delta
		rope_release_vx = move_toward(rope_release_vx, 0.0, ROPE_AIR_MOMENTUM_DRAG * delta)
	elif grounded:
		rope_release_vx = 0.0
	if absf(damage_knockback_vx) > 0.1:
		# Um golpe recua o heroi por pouco tempo; depois o joystick retoma.
		travel = damage_knockback_vx * delta
		damage_knockback_vx = move_toward(damage_knockback_vx, 0.0, 600.0 * delta)
	hero_pos.x = _move_x_with_crates(travel)

	var was_grounded := grounded
	var is_jumping := (Input.is_action_just_pressed("ui_accept") or jump_requested) and grounded and not is_crouching
	jump_requested = false
	if is_jumping:
		feedback.burst(hero_pos + Vector2(0.0, -3.0), "jump")
		_play_sfx("jump")
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

	# Captura a borda durante a queda, antes de aplicar os eventos do pouso.
	if _try_grab_ledge():
		feedback.burst(ledge_edge, "ledge")
		if not _check_threat_collisions(previous_foot_y):
			_update_level_progress()
		_update_camera(delta)
		queue_redraw()
		return

	if grounded:
		if not was_grounded:
			landing_timer = 0.16
			feedback.burst(hero_pos + Vector2(0.0, -2.0), "land")
			_play_sfx("land")
		else:
			landing_timer = maxf(0.0, landing_timer - delta)
	else:
		air_time += delta

	# Cair num vao consome uma vida (sem apagar o checkpoint ou medalhas).
	if hero_pos.y > 435.0:
		_lose_life()
		queue_redraw()
		return

	if _check_threat_collisions(previous_foot_y):
		queue_redraw()
		return
	_update_level_progress()
	if stage_complete:
		queue_redraw()
		return

	var desired := "idle"
	if not grounded and jump_texture != null:
		desired = "jump"
	elif is_crouching and jump_texture != null:
		desired = "crouch"
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

	# A camera agora usa o mesmo seguimento em todos os modos.
	_update_camera(delta)
	queue_redraw()


func _setup_sfx() -> void:
	# Dez efeitos 16-bit originais; players independentes permitem sons simultaneos.
	for name in ["jump", "land", "hurt", "hammer", "horn", "pickup", "checkpoint", "lever", "nano", "enemy"]:
		var path: String = "res://assets/sfx/%s.wav" % name
		if not ResourceLoader.exists(path):
			continue
		var audio: AudioStream = load(path) as AudioStream
		if audio == null:
			continue
		var player := AudioStreamPlayer.new()
		player.stream = audio
		player.volume_db = -11.0
		add_child(player)
		sfx_players[name] = player

func _play_sfx(name: String) -> void:
	if not sound_enabled or not sfx_players.has(name):
		return
	var player: AudioStreamPlayer = sfx_players[name] as AudioStreamPlayer
	if player != null:
		player.play()

func _update_camera(delta: float) -> void:
	# Nao deixa a camera congelar ao usar corda, escada ou agarrar bordas.
	var target: float = clampf(hero_pos.x - 215.0, 0.0, Stage.WORLD_WIDTH - SCREEN_WIDTH)
	camera_x = lerpf(camera_x, target, minf(1.0, delta * 6.5))

func _rope_near(x: float, y: float) -> Vector3:
	# Colisao real com o corpo: pode agarrar no meio da corda ou na ponta.
	var hero_top := y - STAND_HEIGHT
	for rope in ropes:
		var rope_bottom := rope.y + rope.z
		if absf(x - rope.x) <= ROPE_GRAB_DISTANCE and hero_top <= rope_bottom + 6.0 and y >= rope.y - 4.0:
			return rope
	return Vector3.ZERO

func _handle_rope(delta: float) -> bool:
	if not swinging:
		var nearby := _rope_near(hero_pos.x, hero_pos.y)
		# Ao soltar, o Chapolin deve se afastar antes de agarrar a mesma corda.
		if rope_blocked_anchor_x >= 0.0 and (nearby.z <= 0.0 or absf(nearby.x - rope_blocked_anchor_x) > 1.0):
			rope_blocked_anchor_x = -1.0
		if rope_regrab_delay > 0.0 or climbing or nearby.z <= 0.0 or rope_blocked_anchor_x >= 0.0:
			return false
		# Escadas continuam com prioridade se o Chapolin tocar nos dois objetos.
		if _ladder_near(hero_pos.x, hero_pos.y).size.x > 0.0:
			return false
		# Agarra automaticamente; dispensa apertar CIMA.
		swinging = true
		rope_anchor = Vector2(nearby.x, nearby.y)
		rope_length = nearby.z
		rope_grip_distance = clampf(hero_pos.y - ROPE_FOOT_OFFSET - nearby.y, ROPE_MIN_GRIP, rope_length)
		rope_angle = clampf((hero_pos.x - nearby.x) / maxf(rope_grip_distance, 1.0), -0.30, 0.30)
		rope_angular_velocity = 0.0
		rope_release_vx = 0.0
		grounded = false
		climbing = false
		running = false
		is_crouching = false
		vertical_speed = 0.0
		run_hold_time = 0.0
		landing_timer = 0.0

	if Input.is_action_just_pressed("ui_accept") or jump_requested:
		# A velocidade real de soltura e tangente ao circulo descrito pela
		# pegada. Transfere tanto o componente horizontal quanto o vertical.
		var tangent := Vector2(cos(rope_angle), -sin(rope_angle))
		var tangential_speed := rope_angular_velocity * rope_grip_distance
		var launch_velocity := tangent * tangential_speed * ROPE_LAUNCH_MULTIPLIER
		swinging = false
		rope_blocked_anchor_x = rope_anchor.x
		rope_regrab_delay = 0.85
		rope_release_vx = clampf(launch_velocity.x, -ROPE_LAUNCH_MAX_SPEED, ROPE_LAUNCH_MAX_SPEED)
		# O botao PULO acrescenta impulso para cima mesmo no ponto mais baixo.
		vertical_speed = maxf(-390.0, minf(-125.0, launch_velocity.y - ROPE_LAUNCH_UPWARD_BOOST))
		grounded = false
		air_time = 0.0
		jump_requested = false
		_update_climb_visuals(delta, "jump")
		return true

	# Joystick vertical desloca as maos ao longo de toda a corda.
	# Diagonais permitem escalar enquanto o corpo balanca.
	var climb_axis := Input.get_axis("ui_up", "ui_down")
	if joystick_touch_id != -1 and absf(joystick_offset.y) > JOYSTICK_DEADZONE:
		climb_axis = clampf(joystick_offset.y / JOYSTICK_RADIUS, -1.0, 1.0)
	rope_grip_distance = clampf(rope_grip_distance + climb_axis * ROPE_CLIMB_SPEED * delta, ROPE_MIN_GRIP, rope_length)

	var axis := Input.get_axis("ui_left", "ui_right")
	if absf(axis) < 0.1:
		axis = move_axis
	rope_angular_velocity += (-sin(rope_angle) * 5.0 + axis * ROPE_SWING_ACCEL) * delta
	rope_angular_velocity *= maxf(0.0, 1.0 - 1.1 * delta)
	rope_angle += rope_angular_velocity * delta
	if rope_angle >= ROPE_MAX_ANGLE:
		rope_angle = ROPE_MAX_ANGLE
		rope_angular_velocity = minf(0.0, rope_angular_velocity)
	elif rope_angle <= -ROPE_MAX_ANGLE:
		rope_angle = -ROPE_MAX_ANGLE
		rope_angular_velocity = maxf(0.0, rope_angular_velocity)

	var rope_direction := Vector2(sin(rope_angle), cos(rope_angle))
	hero_pos = rope_anchor + rope_direction * rope_grip_distance + Vector2(0.0, ROPE_FOOT_OFFSET)
	hero_pos.x = clampf(hero_pos.x, HERO_HALF_WIDTH, Stage.WORLD_WIDTH - HERO_HALF_WIDTH)
	vertical_speed = 0.0
	air_time = 0.0
	if absf(axis) > 0.1:
		facing = 1 if axis > 0.0 else -1
	_update_climb_visuals(delta, "rope")
	return true

func _ledge_destination_is_clear(destination: Vector2) -> bool:
	# Nao coloca o Chapolin dentro de uma viga, caixa ou grade.
	var bounds := Rect2(destination.x - HERO_HALF_WIDTH, destination.y - STAND_HEIGHT, HERO_HALF_WIDTH * 2.0, STAND_HEIGHT - 1.0)
	for beam in low_beams + nano_tunnels:
		if bounds.intersects(beam):
			return false
	for block in crates:
		if bounds.intersects(block):
			return false
	if not puzzle_gate_open:
		for gate in puzzle_gates:
			if bounds.intersects(gate):
				return false
	if not _lever_gate_open() and bounds.intersects(lever_gate):
		return false
	for i in range(fragile_walls.size()):
		if not fragile_broken[i] and bounds.intersects(fragile_walls[i]):
			return false
	return true

func _try_grab_ledge() -> bool:
	# Somente bordas autorizadas pela fase; caixas comuns nao oferecem apoio.
	# Mantem a captura automatica enquanto cai, mas so se estiver voltado
	# para a borda sinalizada. Evita agarramentos a todo instante.
	if grounded or vertical_speed <= 0.0 or _nano_active() or swinging or climbing or ledge_cooldown > 0.0:
		return false
	for grip in ledge_grab_points:
		var edge_x: float = grip.x
		var top: float = grip.y
		var side: int = int(grip.z)
		if facing != side:
			continue
		var feet_drop: float = hero_pos.y - top
		if feet_drop < LEDGE_GRAB_Y_MIN or feet_drop > LEDGE_GRAB_Y_MAX:
			continue
		var target_x: float = edge_x - float(side) * LEDGE_HANG_SIDE_OFFSET
		if absf(hero_pos.x - target_x) > LEDGE_GRAB_X_TOLERANCE:
			continue
		var candidate_edge := Vector2(edge_x, top)
		if candidate_edge.distance_to(ledge_blocked_edge) < 2.0:
			continue
		var landing_x: float = edge_x + float(side) * (HERO_HALF_WIDTH + 6.0)
		var landing := Vector2(landing_x, top)
		if not _ledge_destination_is_clear(landing):
			continue
		ledge_hanging = true
		ledge_climbing = false
		ledge_edge = candidate_edge
		ledge_side = side
		hero_pos = candidate_edge + Vector2(-float(side) * LEDGE_HANG_SIDE_OFFSET, LEDGE_HANG_DEPTH)
		grounded = false
		vertical_speed = 0.0
		rope_release_vx = 0.0
		damage_knockback_vx = 0.0
		running = false
		is_crouching = false
		jump_requested = false
		run_hold_time = 0.0
		air_time = 0.0
		_update_climb_visuals(0.0, "ledge")
		return true
	return false

func _handle_ledge(delta: float) -> void:
	if ledge_climbing:
		ledge_climb_elapsed += delta
		var fraction: float = clampf(ledge_climb_elapsed / LEDGE_CLIMB_SECONDS, 0.0, 1.0)
		var eased: float = fraction * fraction * (3.0 - 2.0 * fraction)
		hero_pos = ledge_climb_from.lerp(ledge_climb_to, eased)
		if fraction >= 1.0:
			ledge_climbing = false
			grounded = true
			vertical_speed = 0.0
			landing_timer = 0.10
			ledge_cooldown = LEDGE_RELEASE_DELAY
			_update_climb_visuals(delta, "idle")
		else:
			_update_climb_visuals(delta, "ledge_climb")
		return

	if not ledge_hanging:
		return
	var up: bool = climb_up_held or Input.is_action_pressed("ui_up")
	var down: bool = climb_down_held or Input.is_action_pressed("ui_down")
	if up or Input.is_action_just_pressed("ui_accept") or jump_requested:
		var landing_x: float = ledge_edge.x + float(ledge_side) * (HERO_HALF_WIDTH + 6.0)
		var landing := Vector2(landing_x, ledge_edge.y)
		jump_requested = false
		if _ledge_destination_is_clear(landing):
			ledge_hanging = false
			ledge_climbing = true
			ledge_climb_elapsed = 0.0
			ledge_climb_from = hero_pos
			ledge_climb_to = landing
			_handle_ledge(delta)
			return
	elif down:
		ledge_hanging = false
		ledge_blocked_edge = ledge_edge
		ledge_cooldown = LEDGE_RELEASE_DELAY
		vertical_speed = 38.0
		grounded = false
		air_time = 0.0
		_update_climb_visuals(delta, "fall")
		return

	# Permanece imovel na borda sem gastar tempo da corda ou do pulo.
	hero_pos = ledge_edge + Vector2(-float(ledge_side) * LEDGE_HANG_SIDE_OFFSET, LEDGE_HANG_DEPTH)
	grounded = false
	vertical_speed = 0.0
	facing = ledge_side
	_update_climb_visuals(delta, "ledge")

func _lever_gate_open() -> bool:
	return lever_states.size() > 0 and lever_states[0]

func _nearby_lever_index() -> int:
	if pause_menu_open or stage_complete or game_over or ledge_hanging or ledge_climbing or swinging or climbing:
		return -1
	for i in range(lever_points.size()):
		if lever_states[i]:
			continue
		var lever: Vector3 = lever_points[i]
		if absf(hero_pos.x - lever.x) <= LEVER_REACH and absf(hero_pos.y - lever.y) <= LEVER_HEIGHT_REACH:
			return i
	return -1

func _activate_nearby_lever() -> void:
	var index: int = _nearby_lever_index()
	if index < 0:
		return
	# Disparos unicos: a grade nunca fecha sobre o Chapolin e a plataforma
	# nao desliga quando ele estiver em cima. Mantem estado no autosave.
	lever_states[index] = true
	_mark_save_dirty()
	feedback.burst(Vector2(lever_points[index].x, lever_points[index].y - 32.0), "checkpoint", "ATIVADO")
	_play_sfx("lever")
	queue_redraw()

func _setup_moving_platforms() -> void:
	moving_platform_rects.clear()
	moving_platform_directions.clear()
	for spec in moving_platform_specs:
		var start_x: float = float(spec["min_x"])
		var top_y: float = float(spec["y"])
		var width: float = float(spec["width"])
		moving_platform_rects.append(Rect2(start_x, top_y, width, 14.0))
		moving_platform_directions.append(1.0)

func _advance_moving_platforms(delta: float) -> void:
	# Translada o Chapolin junto com a plataforma em que ele esta apoiado.
	# Nao altera a velocidade do pulo nem exige novo botao no celular.
	for i in range(moving_platform_rects.size()):
		# A segunda plataforma aguarda o acionamento da alavanca.
		if i == 1 and (lever_states.size() < 2 or not lever_states[1]):
			continue
		var spec: Dictionary = moving_platform_specs[i]
		var platform: Rect2 = moving_platform_rects[i]
		var carried: bool = grounded and _on_surface(hero_pos.x, hero_pos.y, platform)
		var direction: float = moving_platform_directions[i]
		var limit_left: float = float(spec["min_x"])
		var limit_right: float = float(spec["max_x"])
		var next_x: float = platform.position.x + direction * float(spec["speed"]) * delta
		if next_x >= limit_right:
			next_x = limit_right
			direction = -1.0
		elif next_x <= limit_left:
			next_x = limit_left
			direction = 1.0
		var displacement: float = next_x - platform.position.x
		moving_platform_rects[i] = Rect2(next_x, platform.position.y, platform.size.x, platform.size.y)
		moving_platform_directions[i] = direction
		if carried and absf(displacement) > 0.0001:
			hero_pos.x = _move_x_with_crates(displacement)

func _ladder_near(x: float, y: float) -> Rect2:
	for ladder in ladders:
		var ladder_center := ladder.position.x + ladder.size.x / 2.0
		if absf(x - ladder_center) <= 28.0 and y >= ladder.position.y - 4.0 and y <= ladder.end.y + 4.0:
			return ladder
	return Rect2()

func _handle_ladder(delta: float) -> bool:
	# Regra de subida/descida em coordenadas do mundo, sem mudar as artes.
	var climb_dir := (1.0 if climb_down_held else 0.0) - (1.0 if climb_up_held else 0.0)
	if absf(climb_dir) < 0.1:
		climb_dir = Input.get_axis("ui_up", "ui_down")
	if not climbing and grounded and absf(climb_dir) > 0.1:
		var possible := _ladder_near(hero_pos.x, hero_pos.y)
		var ascending := climb_dir < 0.0 and hero_pos.y > possible.position.y + 1.0
		var descending := climb_dir > 0.0 and hero_pos.y < possible.end.y - 1.0
		if possible.size.x > 0.0 and (ascending or descending):
			climbing = true
			climb_ladder = possible
			grounded = false
			vertical_speed = 0.0
			running = false
			is_crouching = false
			run_hold_time = 0.0
			landing_timer = 0.0
			hero_pos.x = possible.position.x + possible.size.x / 2.0
	if not climbing:
		return false
	if Input.is_action_just_pressed("ui_accept") or jump_requested:
		# Desprender-se com PULO executa o salto normal neste mesmo quadro.
		climbing = false
		grounded = false
		vertical_speed = JUMP_SPEED
		air_time = 0.0
		jump_requested = false
		return false

	hero_pos.x = climb_ladder.position.x + climb_ladder.size.x / 2.0
	hero_pos.y = clampf(hero_pos.y + climb_dir * CLIMB_SPEED * delta, climb_ladder.position.y, climb_ladder.end.y)
	var at_top := climb_dir < 0.0 and hero_pos.y <= climb_ladder.position.y + 0.01
	var at_bottom := climb_dir > 0.0 and hero_pos.y >= climb_ladder.end.y - 0.01
	if at_top or at_bottom:
		climbing = false
		grounded = true
		vertical_speed = 0.0
		landing_timer = 0.0
		_update_climb_visuals(delta, "idle")
	else:
		air_time = 0.0
		_update_climb_visuals(delta, "climb")
	return true

func _update_climb_visuals(delta: float, desired: String) -> void:
	if desired != current_animation:
		current_animation = desired
		animation_time = 0.0
	else:
		animation_time += delta
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
	for surface in moving_platform_rects:
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
	for surface in moving_platform_rects:
		if _crosses_top(from_y, to_y, x, surface):
			landing = minf(landing, surface.position.y)
	return landing

func _crosses_top(from_y: float, to_y: float, x: float, surface: Rect2) -> bool:
	return from_y <= surface.position.y and to_y >= surface.position.y and x + 6.0 > surface.position.x and x - 6.0 < surface.end.x

func _under_low_beam(x: float, y: float) -> bool:
	# An upright hero would collide with any overhead panel at this position.
	for beam in low_beams:
		if x + HERO_HALF_WIDTH > beam.position.x and x - HERO_HALF_WIDTH < beam.end.x:
			if y > beam.position.y and y - STAND_HEIGHT < beam.end.y:
				return true
	return false

func _is_plate_pressed() -> bool:
	# A caixa precisa apoiar uma porcao significativa sobre a placa.
	for plate in pressure_plates:
		for block in crates:
			var horizontal_overlap: float = maxf(0.0, minf(block.end.x, plate.end.x) - maxf(block.position.x, plate.position.x))
			if horizontal_overlap >= block.size.x * 0.40 and absf(block.end.y - plate.end.y) < 3.0:
				return true
	return false

func _try_push_crate(crate_index: int, delta_x: float) -> bool:
	# Empurra com o joystick, somente em terra firme e sem mover outra caixa.
	if not grounded or absf(delta_x) < 0.0001:
		return false
	var block: Rect2 = crates[crate_index]
	var next_block: Rect2 = Rect2(block.position + Vector2(delta_x, 0.0), block.size)
	if next_block.position.x < 0.0 or next_block.end.x > Stage.WORLD_WIDTH:
		return false
	# Nao deixa a caixa flutuar nem cair em um vao irreversivel.
	var supported := false
	for ground_surface in ground_segments:
		if absf(block.end.y - ground_surface.position.y) <= 2.0:
			if next_block.position.x >= ground_surface.position.x and next_block.end.x <= ground_surface.end.x:
				supported = true
				break
	if not supported:
		return false
	for i in range(crates.size()):
		if i != crate_index and next_block.intersects(crates[i]):
			return false
	if not puzzle_gate_open:
		for gate in puzzle_gates:
			if next_block.intersects(gate):
				return false
	if not _lever_gate_open() and next_block.intersects(lever_gate):
		return false
	for i in range(fragile_walls.size()):
		if not fragile_broken[i] and next_block.intersects(fragile_walls[i]):
			return false
	crates[crate_index] = next_block
	_mark_save_dirty()
	if _is_plate_pressed():
		# Primeiro desafio: a grade permanece aberta depois da ativacao.
		puzzle_gate_open = true
	return true

func _move_x_with_crates(distance: float) -> float:
	var half_width: float = _hero_collision_half_width()
	var next_x: float = clampf(hero_pos.x + distance, half_width, Stage.WORLD_WIDTH - half_width)
	for i in range(crates.size()):
		var block: Rect2 = crates[i]
		# Continua permitindo subir e aterrissar no topo das caixas.
		if hero_pos.y <= block.position.y + 4.0 or hero_pos.y - _hero_collision_height() >= block.end.y:
			continue
		if distance > 0.0 and hero_pos.x + half_width <= block.position.x + 0.001 and next_x + half_width > block.position.x:
			var push_right: float = next_x + half_width - block.position.x
			if not _try_push_crate(i, push_right):
				next_x = block.position.x - half_width
		elif distance < 0.0 and hero_pos.x - half_width >= block.end.x - 0.001 and next_x - half_width < block.end.x:
			var push_left: float = next_x - half_width - block.end.x
			if not _try_push_crate(i, push_left):
				next_x = block.end.x + half_width

	# Obstaculos superiores usam a altura real: normal, agachado ou nano.
	var head_y: float = hero_pos.y - _hero_collision_height()
	for beam in low_beams + nano_tunnels:
		if head_y >= beam.end.y - NANO_TUNNEL_MARGIN or hero_pos.y <= beam.position.y:
			continue
		if distance > 0.0 and hero_pos.x + half_width <= beam.position.x and next_x + half_width > beam.position.x:
			next_x = beam.position.x - half_width
		elif distance < 0.0 and hero_pos.x - half_width >= beam.end.x and next_x - half_width < beam.end.x:
			next_x = beam.end.x + half_width

	# Paineis frageis continuam solidos ate um golpe de marreta.
	for i in range(fragile_walls.size()):
		if fragile_broken[i]:
			continue
		var wall: Rect2 = fragile_walls[i]
		if head_y >= wall.end.y or hero_pos.y <= wall.position.y:
			continue
		if distance > 0.0 and hero_pos.x + half_width <= wall.position.x and next_x + half_width > wall.position.x:
			next_x = wall.position.x - half_width
		elif distance < 0.0 and hero_pos.x - half_width >= wall.end.x and next_x - half_width < wall.end.x:
			next_x = wall.end.x + half_width

	# As grades dos dois desafios tem condicoes independentes.
	if not _lever_gate_open() and head_y < lever_gate.end.y and hero_pos.y > lever_gate.position.y:
		if distance > 0.0 and hero_pos.x + half_width <= lever_gate.position.x and next_x + half_width > lever_gate.position.x:
			next_x = lever_gate.position.x - half_width
		elif distance < 0.0 and hero_pos.x - half_width >= lever_gate.end.x and next_x - half_width < lever_gate.end.x:
			next_x = lever_gate.end.x + half_width

	# A primeira grade ainda depende da caixa sobre a placa de pressao.
	if not puzzle_gate_open:
		for gate in puzzle_gates:
			if head_y >= gate.end.y or hero_pos.y <= gate.position.y:
				continue
			if distance > 0.0 and hero_pos.x + half_width <= gate.position.x and next_x + half_width > gate.position.x:
				next_x = gate.position.x - half_width
			elif distance < 0.0 and hero_pos.x - half_width >= gate.end.x and next_x - half_width < gate.end.x:
				next_x = gate.end.x + half_width
	return next_x

func _reset_enemies() -> void:
	enemy_positions.clear()
	enemy_directions.clear()
	enemy_active.clear()
	enemy_stun.clear()
	for patrol in enemy_patrols:
		enemy_positions.append(Vector2(patrol.x, patrol.z))
		enemy_directions.append(1.0)
		enemy_active.append(true)
		enemy_stun.append(0.0)

func _update_enemy_patrols(delta: float) -> void:
	for i in range(enemy_positions.size()):
		if not enemy_active[i]:
			continue
		if enemy_stun[i] > 0.0:
			enemy_stun[i] = maxf(0.0, enemy_stun[i] - delta)
			continue
		var patrol: Vector3 = enemy_patrols[i]
		var enemy_pos: Vector2 = enemy_positions[i]
		var direction: float = enemy_directions[i]
		enemy_pos.x += direction * ENEMY_SPEED * delta
		if enemy_pos.x >= patrol.y:
			enemy_pos.x = patrol.y
			direction = -1.0
		elif enemy_pos.x <= patrol.x:
			enemy_pos.x = patrol.x
			direction = 1.0
		enemy_positions[i] = enemy_pos
		enemy_directions[i] = direction

func _obstacle_position(obstacle: Vector3, index: int) -> Vector2:
	var center_x: float = (obstacle.x + obstacle.y) * 0.5
	var amplitude: float = (obstacle.y - obstacle.x) * 0.5
	var phase: float = hazard_clock * 1.75 + float(index) * 1.8
	return Vector2(center_x + sin(phase) * amplitude, obstacle.z - OBSTACLE_RADIUS)

func _check_threat_collisions(previous_foot_y: float) -> bool:
	if hurt_grace > 0.0 or stage_complete:
		return false
	var hero_height: float = _hero_collision_height()
	var hero_width: float = _hero_collision_half_width()
	var hero_box := Rect2(hero_pos.x - hero_width, hero_pos.y - hero_height, hero_width * 2.0, hero_height)
	for i in range(enemy_positions.size()):
		if not enemy_active[i]:
			continue
		if enemy_stun[i] > 0.0:
			# Figurantes paralisados nao causam dano por contato.
			continue
		var enemy_pos: Vector2 = enemy_positions[i]
		var enemy_top: float = enemy_pos.y - ENEMY_HEIGHT
		var enemy_box := Rect2(enemy_pos.x - ENEMY_HALF_WIDTH, enemy_top, ENEMY_HALF_WIDTH * 2.0, ENEMY_HEIGHT)
		if not hero_box.intersects(enemy_box):
			continue
		# Ao cair de cima, vence o inimigo e ganha rebote.
		# A colisao lateral tira um coracao e provoca recuo.
		if previous_foot_y <= enemy_top + 6.0 and hero_pos.y > previous_foot_y + 0.1:
			enemy_active[i] = false
			_mark_save_dirty()
			feedback.burst(enemy_pos + Vector2(0.0, -16.0), "enemy", "DERROTADO")
			_play_sfx("enemy")
			hero_pos.y = enemy_top - 3.0
			grounded = false
			vertical_speed = ENEMY_STOMP_BOUNCE
			air_time = 0.0
			landing_timer = 0.0
			return false
		_take_damage(enemy_pos.x)
		return true
	for i in range(moving_obstacles.size()):
		var center: Vector2 = _obstacle_position(moving_obstacles[i], i)
		var obstacle_box := Rect2(center.x - OBSTACLE_RADIUS, center.y - OBSTACLE_RADIUS, OBSTACLE_RADIUS * 2.0, OBSTACLE_RADIUS * 2.0)
		if hero_box.intersects(obstacle_box):
			_take_damage(center.x)
			return true
	return false

func _take_damage(source_x: float) -> void:
	if hurt_grace > 0.0 or game_over or stage_complete:
		return
	health -= 1
	_mark_save_dirty()
	feedback.burst(hero_pos + Vector2(0.0, -48.0), "hurt", "-1 CORACAO")
	_play_sfx("hurt")
	if health <= 0:
		_lose_life()
		return
	# Protecao e recuo apenas quando ainda ha coracoes.
	ledge_hanging = false
	ledge_climbing = false
	hurt_grace = DAMAGE_GRACE
	damage_knockback_vx = -DAMAGE_KNOCKBACK if hero_pos.x < source_x else DAMAGE_KNOCKBACK
	vertical_speed = DAMAGE_RECOIL_UP
	grounded = false
	swinging = false
	climbing = false
	rope_release_vx = 0.0
	running = false
	is_crouching = false
	run_hold_time = 0.0
	landing_timer = 0.0
	air_time = 0.0
	jump_requested = false
	queue_redraw()

func _lose_life() -> void:
	lives = maxi(0, lives - 1)
	health = MAX_HEALTH
	_mark_save_dirty()
	damage_knockback_vx = 0.0
	if lives == 0:
		ledge_hanging = false
		ledge_climbing = false
		game_over = true
		running = false
		swinging = false
		climbing = false
		vertical_speed = 0.0
		_release_joystick()
	else:
		_respawn()
	queue_redraw()

func _nano_active() -> bool:
	return nano_remaining > 0.0

func _hero_collision_height() -> float:
	if _nano_active():
		return STAND_HEIGHT * NANO_SCALE
	return CROUCH_HEIGHT if is_crouching else STAND_HEIGHT

func _hero_collision_half_width() -> float:
	return HERO_HALF_WIDTH * NANO_SCALE if _nano_active() else HERO_HALF_WIDTH

func _inside_nano_passage() -> bool:
	# So mantem o efeito ativo enquanto o personagem esta abaixo do telhado.
	for tunnel in nano_tunnels:
		if hero_pos.y > tunnel.end.y and hero_pos.x + HERO_HALF_WIDTH > tunnel.position.x and hero_pos.x - HERO_HALF_WIDTH < tunnel.end.x:
			return true
	return false

func _update_nano_timer(delta: float) -> void:
	if nano_remaining <= 0.0:
		return
	nano_remaining = maxf(0.0, nano_remaining - delta)
	if nano_remaining <= 0.0 and _inside_nano_passage():
		# Evita crescer dentro da passagem e travar a movimentacao.
		nano_remaining = 0.12

func _use_nano() -> void:
	if game_over or stage_complete or not nano_unlocked or nano_charges <= 0 or _nano_active():
		return
	if swinging or climbing:
		return
	nano_charges -= 1
	_mark_save_dirty()
	feedback.burst(hero_pos + Vector2(0.0, -39.0), "nano", "NANICOLINA")
	_play_sfx("nano")
	nano_remaining = NANO_DURATION
	is_crouching = false
	running = false
	run_hold_time = 0.0
	queue_redraw()

func _collect_nano_pickups() -> void:
	for i in range(nano_pickups.size()):
		if nano_pickup_collected[i]:
			continue
		var pickup: Vector2 = nano_pickups[i]
		if absf(hero_pos.x - pickup.x) <= 24.0 and pickup.y >= hero_pos.y - _hero_collision_height() - 10.0 and pickup.y <= hero_pos.y + 10.0:
			nano_pickup_collected[i] = true
			_mark_save_dirty()
			nano_unlocked = true
			nano_charges = NANO_MAX_CHARGES
			feedback.burst(pickup, "pickup", "NANICOLINA +3")
			_play_sfx("pickup")

func _use_hammer() -> void:
	if stage_complete or game_over or not hammer_unlocked or hammer_cooldown > 0.0:
		return
	hammer_cooldown = HAMMER_COOLDOWN
	hammer_swing_time = HAMMER_SWING_DURATION
	_play_sfx("hammer")
	# Golpe frontal de curto alcance, em terra, escada ou corda.
	for i in range(enemy_positions.size()):
		if not enemy_active[i]:
			continue
		var enemy_pos: Vector2 = enemy_positions[i]
		var forward: float = float(facing) * (enemy_pos.x - hero_pos.x)
		if forward >= -8.0 and forward <= HAMMER_REACH and absf(enemy_pos.y - hero_pos.y) <= 56.0:
			enemy_active[i] = false
			enemy_stun[i] = 0.0
			_mark_save_dirty()
			feedback.burst(enemy_pos + Vector2(0.0, -18.0), "enemy", "MARRETA!")
	# A mesma Marreta tambem destroi paineis de papelao a frente.
	for i in range(fragile_walls.size()):
		if fragile_broken[i]:
			continue
		var wall: Rect2 = fragile_walls[i]
		var near_edge: float = wall.position.x if facing > 0 else wall.end.x
		var forward: float = float(facing) * (near_edge - hero_pos.x)
		var vertical_overlap: bool = hero_pos.y - _hero_collision_height() <= wall.end.y and hero_pos.y >= wall.position.y - 12.0
		if forward >= -5.0 and forward <= HAMMER_REACH and vertical_overlap:
			fragile_broken[i] = true
			break_effects[i] = BREAK_EFFECT_SECONDS
			_mark_save_dirty()
			feedback.burst(wall.get_center(), "wood", "SEGREDO!")
	queue_redraw()

func _use_horn() -> void:
	if stage_complete or game_over or not horn_unlocked or horn_charges <= 0 or horn_cooldown > 0.0:
		return
	horn_charges -= 1
	_mark_save_dirty()
	feedback.burst(hero_pos + Vector2(float(facing) * 24.0, -48.0), "horn")
	_play_sfx("horn")
	horn_cooldown = HORN_COOLDOWN
	horn_effect_time = HORN_EFFECT_DURATION
	horn_blast_origin = hero_pos + Vector2(float(facing) * 28.0, -48.0)
	horn_blast_facing = facing
	# Corneta nao elimina inimigos: paralisa os que estiverem na frente.
	for i in range(enemy_positions.size()):
		if not enemy_active[i]:
			continue
		var enemy_pos: Vector2 = enemy_positions[i]
		var forward: float = float(facing) * (enemy_pos.x - hero_pos.x)
		if forward >= -8.0 and forward <= HORN_RANGE and absf(enemy_pos.y - hero_pos.y) <= 68.0:
			enemy_stun[i] = HORN_STUN_SECONDS
	queue_redraw()

func _collect_combat_pickups() -> void:
	# Inventario acompanha o Chapolin entre danos e retornos ao checkpoint.
	for i in range(combat_pickups.size()):
		if pickup_collected[i]:
			continue
		var pickup: Vector3 = combat_pickups[i]
		if absf(hero_pos.x - pickup.x) > 23.0:
			continue
		if pickup.y < hero_pos.y - STAND_HEIGHT - 9.0 or pickup.y > hero_pos.y + 12.0:
			continue
		var kind: int = int(pickup.z)
		pickup_collected[i] = true
		_mark_save_dirty()
		if kind == 1:
			hammer_unlocked = true
		elif kind == 2:
			horn_unlocked = true
			horn_charges = HORN_MAX_CHARGES
		elif kind == 3:
			horn_unlocked = true
			horn_charges = HORN_MAX_CHARGES
		var caption: String = "MARRETA" if kind == 1 else ("CORNETA" if kind == 2 else "CARGAS +3")
		feedback.burst(Vector2(pickup.x, pickup.y), "pickup", caption)
		_play_sfx("pickup")

func _collect_secret_rewards() -> void:
	for i in range(secret_rewards.size()):
		# Nao entrega o premio sem ter quebrado o painel correspondente.
		if i >= fragile_broken.size() or not fragile_broken[i] or secret_collected[i]:
			continue
		var reward: Vector2 = secret_rewards[i]
		if absf(hero_pos.x - reward.x) > 19.0:
			continue
		if reward.y < hero_pos.y - _hero_collision_height() - 10.0 or reward.y > hero_pos.y + 10.0:
			continue
		secret_collected[i] = true
		secret_count += 1
		if i == 0:
			health = mini(MAX_HEALTH, health + 1)
		else:
			lives = mini(SECRET_LIFE_LIMIT, lives + 1)
		feedback.burst(reward, "secret", "CURA +1" if i == 0 else "VIDA EXTRA")
		_play_sfx("pickup")
		_mark_save_dirty()

func _mark_save_dirty() -> void:
	if not save_dirty:
		save_delay = AUTOSAVE_INTERVAL
	save_dirty = true

func _pack_flags(flags: Array[bool]) -> Array:
	var packed: Array = []
	for flag in flags:
		packed.append(flag)
	return packed

func _pack_crates() -> Array:
	var positions: Array = []
	for block in crates:
		positions.append([block.position.x, block.position.y])
	return positions

func _save_game() -> void:
	# Salvamento local no aparelho. Mantem sprites e arquivos do projeto intactos.
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"checkpoint_active": checkpoint_active,
		"puzzle_gate_open": puzzle_gate_open,
		"crates": _pack_crates(),
		"medals": _pack_flags(medal_collected),
		"combat_pickups": _pack_flags(pickup_collected),
		"nano_pickups": _pack_flags(nano_pickup_collected),
		"enemy_active": _pack_flags(enemy_active),
		"lever_states": _pack_flags(lever_states),
		"fragile_broken": _pack_flags(fragile_broken),
		"secret_collected": _pack_flags(secret_collected),
		"health": health,
		"lives": lives,
		"hammer_unlocked": hammer_unlocked,
		"horn_unlocked": horn_unlocked,
		"horn_charges": horn_charges,
		"nano_unlocked": nano_unlocked,
		"nano_charges": nano_charges,
		"stage_complete": stage_complete,
		"game_over": game_over,
		"intro_seen": intro_seen,
		"checkpoint_story_seen": checkpoint_story_seen,
		"rescue_complete": rescue_complete,
		"sound_enabled": sound_enabled
	}
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		# Falha na gravacao nao interrompe o jogo.
		return
	save_file.store_string(JSON.stringify(data))
	save_file.flush()
	save_dirty = false
	save_delay = 0.0
	save_notice_time = 1.8

func _load_flags(data: Dictionary, key: String, flags: Array[bool]) -> void:
	var serialized: Variant = data.get(key, [])
	if not serialized is Array:
		return
	var entries: Array = serialized
	if entries.size() != flags.size():
		return
	for i in range(flags.size()):
		flags[i] = bool(entries[i])

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		return
	var decoded: Variant = JSON.parse_string(save_file.get_as_text())
	if not decoded is Dictionary:
		return
	var data: Dictionary = decoded
	if int(data.get("version", -1)) != SAVE_VERSION:
		return

	checkpoint_active = bool(data.get("checkpoint_active", false))
	respawn_point = Stage.checkpoint() if checkpoint_active else Stage.RESPAWN
	puzzle_gate_open = bool(data.get("puzzle_gate_open", false))

	var saved_crates: Variant = data.get("crates", [])
	if saved_crates is Array:
		var entries: Array = saved_crates
		if entries.size() == crates.size():
			for i in range(crates.size()):
				var location: Variant = entries[i]
				if not location is Array:
					continue
				var xy: Array = location
				if xy.size() != 2:
					continue
				var block: Rect2 = crates[i]
				var next_x: float = float(xy[0])
				var next_y: float = float(xy[1])
				# Ignora coordenadas invalidas em um arquivo danificado.
				if next_x >= 0.0 and next_x + block.size.x <= Stage.WORLD_WIDTH and absf(next_y - block.position.y) <= 1.0:
					crates[i] = Rect2(next_x, next_y, block.size.x, block.size.y)

	_load_flags(data, "medals", medal_collected)
	_load_flags(data, "combat_pickups", pickup_collected)
	_load_flags(data, "nano_pickups", nano_pickup_collected)
	_load_flags(data, "enemy_active", enemy_active)
	_load_flags(data, "lever_states", lever_states)
	_load_flags(data, "fragile_broken", fragile_broken)
	_load_flags(data, "secret_collected", secret_collected)
	secret_count = secret_collected.count(true)

	medal_count = medal_collected.count(true)
	health = clampi(int(data.get("health", MAX_HEALTH)), 1, MAX_HEALTH)
	lives = clampi(int(data.get("lives", MAX_LIVES)), 0, SECRET_LIFE_LIMIT)
	hammer_unlocked = bool(data.get("hammer_unlocked", false))
	horn_unlocked = bool(data.get("horn_unlocked", false))
	horn_charges = clampi(int(data.get("horn_charges", 0)), 0, HORN_MAX_CHARGES)
	nano_unlocked = bool(data.get("nano_unlocked", false))
	nano_charges = clampi(int(data.get("nano_charges", 0)), 0, NANO_MAX_CHARGES)
	stage_complete = bool(data.get("stage_complete", false))
	game_over = bool(data.get("game_over", false)) or lives == 0
	# Saves antigos nao devem interromper o jogador com cenas inesperadas.
	sound_enabled = bool(data.get("sound_enabled", true))
	intro_seen = bool(data.get("intro_seen", true))
	checkpoint_story_seen = bool(data.get("checkpoint_story_seen", checkpoint_active))
	rescue_complete = bool(data.get("rescue_complete", stage_complete))
	if stage_complete:
		game_over = false
		finish_medals = medal_count
	hero_pos = respawn_point
	camera_x = clampf(hero_pos.x - 215.0, 0.0, Stage.WORLD_WIDTH - SCREEN_WIDTH)
	hurt_grace = DAMAGE_GRACE

func _exit_tree() -> void:
	# Desligar a cena grava mudancas ainda pendentes.
	if save_dirty:
		_save_game()

func _start_story(scene_id: String) -> void:
	var pages: Array[Dictionary] = Stage.story_dialogue(scene_id)
	if pages.is_empty():
		return
	story_scene_id = scene_id
	story_pages = pages
	story_step = 0
	story_active = true
	pause_menu_open = false
	_release_joystick()
	jump_requested = false
	queue_redraw()

func _advance_story() -> void:
	if not story_active:
		return
	story_step += 1
	if story_step >= story_pages.size():
		_finish_story()
	else:
		queue_redraw()

func _finish_story() -> void:
	if not story_active:
		return
	if story_scene_id == "intro":
		intro_seen = true
		stage_banner_timer = STAGE_BANNER_DURATION
	elif story_scene_id == "checkpoint":
		checkpoint_story_seen = true
	story_active = false
	story_scene_id = ""
	story_step = 0
	story_pages.clear()
	jump_requested = false
	_mark_save_dirty()
	queue_redraw()

func _update_level_progress() -> void:
	_collect_combat_pickups()
	_collect_nano_pickups()
	_collect_secret_rewards()
	# As medalhas sao opcionais, coletadas ao tocar no corpo do heroi.
	# O progresso permanece quando ele cai e retorna ao checkpoint.
	for i in range(medals.size()):
		if medal_collected[i]:
			continue
		var medal: Vector2 = medals[i]
		if absf(hero_pos.x - medal.x) <= 19.0 and medal.y >= hero_pos.y - STAND_HEIGHT - 5.0 and medal.y <= hero_pos.y + 9.0:
			medal_collected[i] = true
			medal_count += 1
			_mark_save_dirty()
			feedback.burst(medal, "medal", "+ MEDALHA")
			_play_sfx("pickup")

	var mark: Vector2 = Stage.checkpoint()
	if not checkpoint_active and grounded:
		if absf(hero_pos.x - mark.x) <= 31.0 and absf(hero_pos.y - mark.y) <= 7.0:
			checkpoint_active = true
			respawn_point = mark
			_mark_save_dirty()
			feedback.burst(mark + Vector2(0.0, -52.0), "checkpoint", "CHECKPOINT!")
			_play_sfx("checkpoint")
			if not checkpoint_story_seen:
				checkpoint_story_seen = true
				_start_story("checkpoint")

	var door: Rect2 = Stage.exit_door()
	if not stage_complete and puzzle_gate_open and grounded:
		if hero_pos.x >= door.position.x - 4.0 and hero_pos.x <= door.end.x + 4.0:
			if absf(hero_pos.y - door.end.y) < 8.0:
				finish_medals = medal_count
				stage_complete = true
				rescue_complete = true
				_mark_save_dirty()
				move_axis = 0.0
				running = false
				jump_requested = false
				_start_story("rescue")

func _restart_stage() -> void:
	# Recomeca a fase inteira; cair ou levar dano nao apaga o progresso.
	run_touch_id = -1
	feedback.reset()
	title_active = false
	stage_banner_timer = 0.0
	pause_menu_open = false
	story_active = false
	intro_seen = false
	checkpoint_story_seen = false
	rescue_complete = false
	story_step = 0
	story_scene_id = ""
	story_pages.clear()
	health = MAX_HEALTH
	lives = MAX_LIVES
	game_over = false
	damage_knockback_vx = 0.0
	nano_unlocked = false
	nano_charges = 0
	nano_remaining = 0.0
	for i in range(nano_pickup_collected.size()):
		nano_pickup_collected[i] = false
	hammer_unlocked = false
	horn_unlocked = false
	horn_charges = 0
	hammer_cooldown = 0.0
	hammer_swing_time = 0.0
	horn_cooldown = 0.0
	horn_effect_time = 0.0
	for i in range(pickup_collected.size()):
		pickup_collected[i] = false
	puzzle_gate_open = false
	secret_count = 0
	for i in range(fragile_broken.size()):
		fragile_broken[i] = false
		break_effects[i] = 0.0
	for i in range(secret_collected.size()):
		secret_collected[i] = false
	for i in range(lever_states.size()):
		lever_states[i] = false
	crates = Stage.crates()
	checkpoint_active = false
	respawn_point = Stage.RESPAWN
	stage_complete = false
	finish_medals = 0
	medal_count = 0
	hazard_clock = 0.0
	_setup_moving_platforms()
	_reset_enemies()
	for i in range(medal_collected.size()):
		medal_collected[i] = false
	_release_joystick()
	_respawn()
	camera_x = 0.0
	current_animation = "idle"
	animation_time = 0.0
	_save_game()
	_start_story("intro")
	queue_redraw()

func _respawn() -> void:
	run_touch_id = -1
	hero_pos = respawn_point
	nano_remaining = 0.0
	hurt_grace = DAMAGE_GRACE
	damage_knockback_vx = 0.0
	vertical_speed = 0.0
	grounded = true
	move_axis = 0.0
	running = false
	swinging = false
	rope_anchor = Vector2.ZERO
	rope_length = 0.0
	rope_grip_distance = 0.0
	rope_blocked_anchor_x = -1.0
	rope_angle = 0.0
	rope_angular_velocity = 0.0
	rope_release_vx = 0.0
	rope_regrab_delay = 0.0
	climbing = false
	climb_ladder = Rect2()
	ledge_hanging = false
	ledge_climbing = false
	ledge_edge = Vector2.ZERO
	ledge_side = 1
	ledge_cooldown = 0.0
	ledge_blocked_edge = Vector2(-1000.0, -1000.0)
	ledge_climb_elapsed = 0.0
	climb_up_held = false
	climb_down_held = false
	is_crouching = false
	run_hold_time = 0.0
	run_direction = 0
	jump_requested = false
	air_time = 0.0
	landing_timer = 0.0

func _draw() -> void:
	# Noite azul-violeta como na arte aprovada. Nenhuma arte do heroi e alterada.
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color("#11172d"))
	if sky_panorama == null and city_bg_art == null:
		draw_rect(Rect2(0.0, 25.0, 640.0, 274.0), Color("#35406a"))
		draw_rect(Rect2(0.0, 156.0, 640.0, 144.0), Color("#5d547b"))
	draw_rect(Rect2(0.0, 300.0, 640.0, 60.0), Color("#292235"))

	draw_set_transform(Vector2(-camera_x * 0.15, 0.0), 0.0, Vector2.ONE)
	_draw_far_buildings()
	draw_set_transform(Vector2(-camera_x * 0.52, 0.0), 0.0, Vector2.ONE)
	_draw_near_buildings()

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if city_lights_art == null:
		_draw_stage_lighting()

	draw_set_transform(Vector2(-camera_x, 0.0), 0.0, Vector2.ONE)
	_draw_decoration()
	_draw_studio_set_details()
	for ladder in ladders:
		_draw_ladder(ladder)
	for surface in ground_segments:
		_draw_stone(surface, true)
	for surface in raised_platforms:
		_draw_stone(surface, false)
	for i in range(moving_platform_rects.size()):
		var powered: bool = i == 0 or (lever_states.size() > 1 and lever_states[1])
		_draw_moving_platform(moving_platform_rects[i], moving_platform_specs[i], powered)
	_draw_ledge_grab_markers()
	for plate in pressure_plates:
		_draw_pressure_plate(plate)
	for gate in puzzle_gates:
		_draw_puzzle_gate(gate)
	_draw_lever_gate()
	for lever_index in range(lever_points.size()):
		_draw_lever(lever_index)
	for i in range(fragile_walls.size()):
		if not fragile_broken[i]:
			_draw_fragile_wall(fragile_walls[i])
		elif break_effects[i] > 0.0:
			_draw_paper_debris(fragile_walls[i], break_effects[i])
	for block in crates:
		_draw_crate(block)
	for beam in low_beams:
		_draw_low_beam(beam)
	for tunnel in nano_tunnels:
		_draw_nano_tunnel(tunnel)
	for rope in ropes:
		_draw_rope(rope)
	_draw_checkpoint()
	_draw_rescue_npc()
	_draw_exit_door()
	for i in range(medals.size()):
		if not medal_collected[i]:
			_draw_medal(medals[i])
	for i in range(secret_rewards.size()):
		if i < fragile_broken.size() and fragile_broken[i] and not secret_collected[i]:
			_draw_secret_medal(secret_rewards[i])
	for i in range(combat_pickups.size()):
		if not pickup_collected[i]:
			_draw_combat_pickup(combat_pickups[i])
	for i in range(nano_pickups.size()):
		if not nano_pickup_collected[i]:
			_draw_nano_pickup(nano_pickups[i])
	if horn_effect_time > 0.0:
		_draw_horn_wave()
	for i in range(enemy_positions.size()):
		if enemy_active[i]:
			_draw_paper_enemy(enemy_positions[i], enemy_directions[i], enemy_stun[i] > 0.0)
	for i in range(moving_obstacles.size()):
		_draw_rolling_obstacle(_obstacle_position(moving_obstacles[i], i))
	if hurt_grace > 0.0:
		_draw_respawn_shield()
	if hammer_swing_time > 0.0:
		_draw_hammer_swing()
	if ledge_hanging:
		_draw_ledge_grip()

	# O Chapolin usa os sprites oficiais: nenhum pixel dele foi alterado.
	var hero_scale: float = NANO_SCALE if _nano_active() else 1.0
	draw_set_transform(Vector2(roundf(hero_pos.x - camera_x), roundf(hero_pos.y)), 0.0, Vector2(float(facing) * hero_scale, hero_scale))
	# Pisca durante a invulnerabilidade sem alterar os sprites oficiais.
	if hurt_grace <= 0.0 or int(hurt_grace * 14.0) % 2 == 0:
		_draw_chapolin()
	draw_set_transform(Vector2(-camera_x, 0.0), 0.0, Vector2.ONE)
	feedback.draw_on(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if city_lights_art != null:
		# O pano dos refletores vem depois dos personagens mas antes do HUD:
		# feixes e cortinas se sobrepoem a cena, nunca aos controles.
		draw_texture_rect(city_lights_art, Rect2(0.0, 0.0, SCREEN_WIDTH, 360.0), false, Color(1.0, 1.0, 1.0, 0.67))
	_draw_cinematic_atmosphere()
	_draw_controls()
	# A cartela antiga de prologo foi aposentada: a HUD v3 ja mostra
	# titulo e objetivo. Nao desenhar nenhum segundo banner durante a fase.
	if pause_menu_open:
		_draw_pause_inventory()
	if stage_complete:
		_draw_finish_screen()
	elif game_over:
		_draw_game_over()
	if story_active:
		_draw_story_scene()
	if title_active:
		_draw_title_screen()

func _begin_from_title(new_game: bool) -> void:
	if not title_active:
		return
	run_touch_id = -1
	title_active = false
	_release_joystick()
	jump_requested = false
	if new_game:
		# A rotina de reinicio ja limpa inventario e inicia o prologo.
		_restart_stage()
	else:
		# Continua do ultimo checkpoint sem descartar o arquivo salvo.
		stage_banner_timer = STAGE_BANNER_DURATION
	queue_redraw()

func _draw_cinematic_atmosphere() -> void:
	# Camada barata para mobile: vinheta suave e poeira cenografica.
	draw_rect(Rect2(0.0, 0.0, 7.0, 360.0), Color(0.03, 0.03, 0.07, 0.26))
	draw_rect(Rect2(633.0, 0.0, 7.0, 360.0), Color(0.03, 0.03, 0.07, 0.26))
	draw_rect(Rect2(0.0, 345.0, 640.0, 15.0), Color(0.03, 0.03, 0.07, 0.23))
	for i in range(11):
		var drift: float = scene_ambience_clock * (4.0 + float(i % 4))
		var x: float = fposmod(35.0 + float(i * 71) + drift - camera_x * 0.07, 640.0)
		var y: float = 85.0 + float((i * 41) % 192) + sin(scene_ambience_clock * 0.6 + float(i)) * 7.0
		draw_circle(Vector2(x, y), 1.3 if i % 3 == 0 else 0.8, Color(0.98, 0.84, 0.63, 0.24))

func _draw_title_screen() -> void:
	# Abertura com tipografia, escudo e o sprite oficial do personagem.
	# A cidade aparece ao fundo; nenhum arquivo de arte e substituido.
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color(0.03, 0.04, 0.08, 0.93))
	draw_rect(Rect2(0.0, 0.0, 640.0, 28.0), Color("#171522"))
	draw_rect(Rect2(0.0, 336.0, 640.0, 24.0), Color("#171522"))
	for i in range(20):
		var frame_x: float = 12.0 + float(i) * 32.0
		draw_rect(Rect2(frame_x, 8.0, 14.0, 10.0), Color("#51434b"))
		draw_rect(Rect2(frame_x, 343.0, 14.0, 10.0), Color("#51434b"))
	var glow: float = 0.06 + sin(title_clock * 1.2) * 0.02
	draw_circle(Vector2(490.0, 157.0), 114.0, Color(0.88, 0.43, 0.20, glow))
	draw_circle(Vector2(490.0, 157.0), 85.0, Color(0.85, 0.48, 0.24, 0.10))
	# Moldura vertical de poster televisivo.
	draw_rect(Rect2(425.0, 55.0, 126.0, 219.0), Color("#48363d"))
	draw_rect(Rect2(429.0, 59.0, 118.0, 211.0), Color("#7e5145"))
	if idle_texture != null:
		var frame_width: float = float(idle_texture.get_width()) / 8.0
		var frame_height: float = float(idle_texture.get_height())
		draw_texture_rect_region(idle_texture, Rect2(437.0, 74.0, 104.0, 190.0), Rect2(0.0, 0.0, frame_width, frame_height), Color.WHITE, false, true)
	draw_rect(Rect2(45.0, 76.0, 344.0, 3.0), Color("#d69a4e"))
	draw_string(ThemeDB.fallback_font, Vector2(44.0, 123.0), "CHAPOLIN", HORIZONTAL_ALIGNMENT_LEFT, -1, 48, Color("#f8e2b4"))
	draw_string(ThemeDB.fallback_font, Vector2(48.0, 162.0), "ADVENTURES", HORIZONTAL_ALIGNMENT_LEFT, -1, 31, Color("#db8650"))
	draw_rect(Rect2(47.0, 177.0, 275.0, 1.0), Color("#6f5550"))
	draw_string(ThemeDB.fallback_font, Vector2(48.0, 199.0), "UMA AVENTURA EM ESTILO RETRO", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#e0c9ac"))
	draw_string(ThemeDB.fallback_font, Vector2(48.0, 220.0), "NO UNIVERSO DO HEROI COLORADO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#bca797"))
	draw_rect(TITLE_PLAY_RECT, Color("#b86d37"))
	draw_rect(Rect2(64.0, 249.0, 203.0, 46.0), Color("#754735"))
	draw_rect(TITLE_NEW_RECT, Color("#554551"))
	draw_rect(Rect2(290.0, 249.0, 203.0, 46.0), Color("#302f40"))
	var main_label := "CONTINUAR" if title_has_save else "JOGAR"
	draw_string(ThemeDB.fallback_font, Vector2(100.0, 280.0), main_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("#fff2dc"))
	draw_string(ThemeDB.fallback_font, Vector2(314.0, 280.0), "NOVO JOGO", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#f0d7bb"))
	draw_string(ThemeDB.fallback_font, Vector2(68.0, 324.0), "AVENTURA 01  |  CIDADE DE PAPELAO", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c4aa94"))
	if title_has_save:
		draw_string(ThemeDB.fallback_font, Vector2(318.0, 310.0), "REINICIA O PROGRESSO", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#b9a498"))

func _draw_far_buildings() -> void:
	if city_bg_art != null:
		# Fundo distante e largo o suficiente para o deslocamento de camera
		# (max. 1760 * fator 0.15 = 264, largura 1024).
		draw_texture(city_bg_art, Vector2.ZERO)
		return
	if sky_panorama != null:
		draw_texture(sky_panorama, Vector2.ZERO)
		return
	# Fundo original de seguranca, quando o SVG nao for importado.
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
	if city_mid_art != null:
		# Fachadas em 3 paineis para cobrir os 2400px de fase, sem alterar
		# plataformas nem criar paredes falsas no caminho do Chapolin.
		for panel in range(3):
			draw_texture(city_mid_art, Vector2(float(panel) * 1024.0, 0.0))
		return
	if city_facades != null:
		# Tres paineis em parallax; so cenografia, sem colisao nova.
		for i in range(3):
			draw_texture(city_facades, Vector2(float(i) * 1024.0, 0.0))
		return
	# Fachadas originais permanecem como fallback caso falte a textura.
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
	# Refletores e trelicas de um estudio de 1975; luz quente contra a noite azul.
	for i in range(4):
		var lamp_x: float = 65.0 + float(i) * 169.0
		var beam_alpha: float = 0.052 + 0.009 * sin(scene_ambience_clock * 1.6 + float(i))
		draw_colored_polygon(PackedVector2Array([
			Vector2(lamp_x - 3.0, 41.0),
			Vector2(lamp_x + 5.0, 41.0),
			Vector2(lamp_x + 108.0, 300.0),
			Vector2(lamp_x - 112.0, 300.0)
		]), Color(1.0, 0.74, 0.45, beam_alpha))
	draw_rect(Rect2(0.0, 0.0, 640.0, 19.0), Color("#191a2b"))
	draw_rect(Rect2(0.0, 19.0, 640.0, 4.0), Color("#4a3856"))
	# Trelicas cruzadas e ganchos ao longo do teto.
	for i in range(11):
		var rig_x: float = float(i) * 65.0
		draw_line(Vector2(rig_x, 0.0), Vector2(rig_x + 32.0, 20.0), Color("#68506a"), 2.0)
		draw_line(Vector2(rig_x + 32.0, 0.0), Vector2(rig_x, 20.0), Color("#68506a"), 2.0)
	for x in [59.0, 230.0, 400.0, 564.0]:
		draw_line(Vector2(x, 22.0), Vector2(x, 38.0), Color("#3d3446"), 3.0)
		draw_rect(Rect2(x - 15.0, 38.0, 30.0, 17.0), Color("#262637"))
		draw_rect(Rect2(x - 11.0, 42.0, 22.0, 9.0), Color("#4b4353"))
		draw_rect(Rect2(x - 8.0, 51.0, 16.0, 3.0), Color("#efc189"))
		draw_circle(Vector2(x, 53.0), 15.0, Color(1.0, 0.78, 0.45, 0.12))

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

func _draw_studio_set_details() -> void:
	# Cenografia nao-colisiva inspirada no estudio de televisao da referencia.
	# Totens, refletores, letreiros e objetos ao fundo das plataformas.
	draw_rect(Rect2(25.0, 118.0, 132.0, 80.0), Color("#4b3542"))
	draw_rect(Rect2(30.0, 123.0, 122.0, 70.0), Color("#d7b18b"))
	draw_rect(Rect2(33.0, 126.0, 116.0, 64.0), Color("#d8b78d"))
	draw_string(ThemeDB.fallback_font, Vector2(43.0, 151.0), "CIDADE DE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#68444b"))
	draw_string(ThemeDB.fallback_font, Vector2(39.0, 178.0), "PAPELAO", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#5d3940"))
	for pole_x in [35.0, 147.0]:
		draw_line(Vector2(pole_x, 193.0), Vector2(pole_x, 300.0), Color("#77503d"), 6.0)
		draw_line(Vector2(pole_x, 202.0), Vector2(pole_x + 19.0, 286.0), Color("#aa7550"), 3.0)
	# Claquete e camara televisiva junto ao primeiro trecho, fora dos controles.
	draw_rect(Rect2(18.0, 264.0, 43.0, 28.0), Color("#282637"))
	draw_rect(Rect2(24.0, 270.0, 31.0, 16.0), Color("#514b5f"))
	draw_circle(Vector2(21.0, 265.0), 8.0, Color("#25243b"))
	draw_circle(Vector2(52.0, 265.0), 8.0, Color("#25243b"))
	draw_line(Vector2(30.0, 292.0), Vector2(19.0, 316.0), Color("#50455c"), 3.0)
	draw_line(Vector2(45.0, 292.0), Vector2(53.0, 316.0), Color("#50455c"), 3.0)
	draw_line(Vector2(38.0, 292.0), Vector2(38.0, 318.0), Color("#50455c"), 3.0)
	# Placas de cinema ao lado da segunda alavanca; nao escondem o comando.
	draw_rect(Rect2(1960.0, 140.0, 116.0, 78.0), Color("#674856"))
	draw_rect(Rect2(1965.0, 145.0, 106.0, 68.0), Color("#d2ad84"))
	draw_string(ThemeDB.fallback_font, Vector2(1974.0, 168.0), "GRANDE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#79404b"))
	draw_string(ThemeDB.fallback_font, Vector2(1974.0, 190.0), "ESPETACULO", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#79404b"))
	draw_string(ThemeDB.fallback_font, Vector2(1986.0, 207.0), "DA TV", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#79404b"))
	# Lanternas de cena em locais especificos, com pulsacao suave.
	for lamp_x in [432.0, 963.0, 1846.0, 2224.0]:
		var light_y := 177.0 if lamp_x < 1000.0 else 186.0
		var flicker: float = 0.83 + sin(scene_ambience_clock * 2.3 + lamp_x) * 0.08
		draw_rect(Rect2(lamp_x - 7.0, light_y - 8.0, 14.0, 16.0), Color("#4c2c42"))
		draw_rect(Rect2(lamp_x - 3.0, light_y - 5.0, 6.0, 10.0), Color(1.0, 0.49 * flicker, 0.30 * flicker))
		draw_circle(Vector2(lamp_x, light_y), 17.0, Color(1.0, 0.38, 0.18, 0.09 * flicker))

func _draw_art_floor(surface: Rect2) -> void:
	# Faixa da madeira produzida na arte: acompanha o topo colidivel.
	# O original inteiro NAO e colado sobre a fase (evita pisos falsos).
	if city_set_art == null:
		return
	var offset: float = 0.0
	while offset < surface.size.x:
		var step: float = minf(125.0, surface.size.x - offset)
		var dest := Rect2(surface.position.x + offset, surface.position.y - 6.0, step, 68.0)
		var src := Rect2(423.0, 287.0, step, 68.0)
		draw_texture_rect_region(city_set_art, dest, src)
		offset += step

func _draw_art_platform_top(surface: Rect2) -> void:
	if city_set_art == null:
		return
	var offset: float = 0.0
	while offset < surface.size.x:
		var step: float = minf(112.0, surface.size.x - offset)
		var dest := Rect2(surface.position.x + offset, surface.position.y - 6.0, step, 20.0)
		var src := Rect2(517.0, 129.0, step, 22.0)
		draw_texture_rect_region(city_set_art, dest, src)
		offset += step

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
		_draw_art_platform_top(surface)
	else:
		_draw_art_floor(surface)

func _draw_pressure_plate(plate: Rect2) -> void:
	var pressed := _is_plate_pressed()
	var plate_color := Color("#79bc83") if pressed else Color("#d8a75a")
	draw_rect(Rect2(plate.position.x - 3.0, plate.position.y + 1.0, plate.size.x + 6.0, 5.0), Color("#4b3940"))
	draw_rect(plate, plate_color)
	draw_line(Vector2(plate.position.x, plate.position.y), Vector2(plate.end.x, plate.position.y), Color("#f9e5b7"), 2.0)
	draw_circle(Vector2(plate.position.x + 5.0, plate.position.y), 2.0, plate_color)
	draw_circle(Vector2(plate.end.x - 5.0, plate.position.y), 2.0, plate_color)

func _draw_puzzle_gate(gate: Rect2) -> void:
	# Grade de bastidor: o arco fica visivel quando o mecanismo e liberado.
	draw_rect(Rect2(gate.position.x - 4.0, gate.position.y - 5.0, gate.size.x + 8.0, 8.0), Color("#4c3433"))
	draw_rect(Rect2(gate.position.x - 4.0, gate.position.y - 5.0, 5.0, gate.size.y + 5.0), Color("#856650"))
	draw_rect(Rect2(gate.end.x - 1.0, gate.position.y - 5.0, 5.0, gate.size.y + 5.0), Color("#856650"))
	if not puzzle_gate_open:
		draw_rect(Rect2(gate.position.x, gate.position.y, gate.size.x, gate.size.y), Color("#513a39"))
		for i in range(3):
			var bar_x := gate.position.x + 3.0 + float(i) * 6.0
			draw_line(Vector2(bar_x, gate.position.y + 2.0), Vector2(bar_x, gate.end.y), Color("#baa27e"), 3.0)
		draw_line(Vector2(gate.position.x, gate.position.y + 40.0), Vector2(gate.end.x, gate.position.y + 40.0), Color("#76564c"), 5.0)
	var light := Color("#7fca8b") if puzzle_gate_open else Color("#e2a26d")
	draw_circle(Vector2(gate.position.x + gate.size.x / 2.0, gate.position.y - 10.0), 5.0, light)

func _draw_nano_tunnel(tunnel: Rect2) -> void:
	# Pequena passagem por baixo do painel, deixando apenas 36px de altura.
	draw_rect(tunnel, Color("#49363a"))
	draw_rect(Rect2(tunnel.position.x + 3.0, tunnel.position.y + 2.0, tunnel.size.x - 6.0, tunnel.size.y - 5.0), Color("#bd926d"))
	draw_line(Vector2(tunnel.position.x, tunnel.end.y - 2.0), Vector2(tunnel.end.x, tunnel.end.y - 2.0), Color("#f0c79d"), 3.0)
	draw_line(tunnel.position + Vector2(5.0, 2.0), tunnel.end - Vector2(5.0, 2.0), Color("#795356"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(tunnel.position.x + 3.0, tunnel.position.y - 8.0), "NANICOLINA", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#ffe7ae"))

func _draw_nano_pickup(pos: Vector2) -> void:
	draw_circle(pos + Vector2(1.0, 2.0), 13.0, Color("#443841"))
	draw_circle(pos, 11.0, Color("#c6d99c"))
	draw_circle(pos, 8.0, Color("#547d5c"))
	draw_rect(Rect2(pos.x - 4.0, pos.y - 8.0, 8.0, 16.0), Color("#eee8b0"))
	draw_rect(Rect2(pos.x - 3.0, pos.y - 6.0, 6.0, 9.0), Color("#8ac3a0"))
	draw_line(pos + Vector2(-3.0, -2.0), pos + Vector2(3.0, -2.0), Color("#d7f2cc"), 2.0)

func _draw_fragile_wall(wall: Rect2) -> void:
	# Painel rachado, identificavel sem icones ou controles adicionais.
	draw_rect(wall, Color("#493840"))
	draw_rect(Rect2(wall.position + Vector2(2.0, 2.0), wall.size - Vector2(4.0, 4.0)), Color("#bd8d67"))
	draw_line(wall.position + Vector2(5.0, 4.0), wall.position + Vector2(15.0, 18.0), Color("#694d4a"), 2.0)
	draw_line(wall.position + Vector2(15.0, 18.0), wall.position + Vector2(8.0, 30.0), Color("#694d4a"), 2.0)
	draw_line(wall.position + Vector2(8.0, 30.0), wall.position + Vector2(17.0, 40.0), Color("#694d4a"), 2.0)
	draw_string(ThemeDB.fallback_font, wall.position + Vector2(-13.0, -8.0), "MARRETA", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f0d09e"))

func _draw_paper_debris(wall: Rect2, time_left: float) -> void:
	var progress: float = 1.0 - time_left / BREAK_EFFECT_SECONDS
	var center: Vector2 = wall.get_center()
	for i in range(6):
		var angle: float = float(i) * TAU / 6.0
		var direction := Vector2(cos(angle), sin(angle))
		var piece: Vector2 = center + direction * (5.0 + 29.0 * progress)
		draw_rect(Rect2(piece.x - 3.0, piece.y - 2.0, 6.0, 4.0), Color("#cfaa83"))

func _draw_secret_medal(pos: Vector2) -> void:
	draw_circle(pos, 11.0, Color("#f6daa0"))
	draw_circle(pos, 8.0, Color("#9b687e"))
	draw_circle(pos, 5.0, Color("#f3de9e"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(-4.0, 4.0), "S", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#503746"))

func _draw_combat_pickup(pickup: Vector3) -> void:
	var pos := Vector2(pickup.x, pickup.y)
	var kind: int = int(pickup.z)
	draw_circle(pos + Vector2(1.0, 2.0), 14.0, Color("#3a343a"))
	draw_circle(pos, 12.0, Color("#deb983"))
	draw_circle(pos, 9.0, Color("#4b3e46"))
	if kind == 1:
		# Cabo e cabeca da marreta.
		draw_line(pos + Vector2(-3.0, 7.0), pos + Vector2(5.0, -6.0), Color("#d0a476"), 3.0)
		draw_rect(Rect2(pos.x - 2.0, pos.y - 10.0, 14.0, 6.0), Color("#a7aab0"))
	elif kind == 2:
		# Cone de sopro da corneta.
		draw_line(pos + Vector2(-8.0, 4.0), pos + Vector2(2.0, 4.0), Color("#e5bc72"), 4.0)
		draw_colored_polygon(PackedVector2Array([
			pos + Vector2(1.0, 2.0), pos + Vector2(9.0, -4.0), pos + Vector2(9.0, 10.0)
		]), Color("#efce82"))
	else:
		draw_string(ThemeDB.fallback_font, pos + Vector2(-8.0, 5.0), "+3", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f4d585"))

func _draw_hammer_swing() -> void:
	var elapsed: float = 1.0 - hammer_swing_time / HAMMER_SWING_DURATION
	var start: Vector2 = hero_pos + Vector2(float(facing) * 12.0, -57.0)
	var reach: Vector2 = start + Vector2(float(facing) * (23.0 + elapsed * 37.0), -12.0 + elapsed * 16.0)
	draw_line(start, reach, Color("#e1b37c"), 5.0)
	draw_rect(Rect2(reach.x - 11.0, reach.y - 8.0, 22.0, 14.0), Color("#a6adb6"))
	draw_rect(Rect2(reach.x - 8.0, reach.y - 6.0, 16.0, 10.0), Color("#d0d7d9"))

func _draw_horn_wave() -> void:
	var progress: float = 1.0 - horn_effect_time / HORN_EFFECT_DURATION
	var radius: float = 20.0 + HORN_RANGE * progress
	var start_angle: float = -PI * 0.5 if horn_blast_facing > 0 else PI * 0.5
	var end_angle: float = PI * 0.5 if horn_blast_facing > 0 else PI * 1.5
	draw_arc(horn_blast_origin, radius, start_angle, end_angle, 32, Color(0.57, 0.89, 0.99, 0.80 - progress * 0.65), 3.0)
	draw_circle(horn_blast_origin, 6.0, Color("#e2c993"))

func _draw_paper_enemy(pos: Vector2, direction: float, stunned: bool) -> void:
	# Capanga de televisao: boina, bigode e colete, substituindo apenas a
	# aparencia do robo de papelao. A colisao ENEMY_HEIGHT continua intocada.
	var look: float = 1.0 if direction >= 0.0 else -1.0
	# Botas e pernas.
	draw_rect(Rect2(pos.x - 10.0, pos.y - 7.0, 8.0, 7.0), Color("#282836"))
	draw_rect(Rect2(pos.x + 2.0, pos.y - 7.0, 8.0, 7.0), Color("#282836"))
	draw_line(pos + Vector2(-6.0, -13.0), pos + Vector2(-7.0, -3.0), Color("#343445"), 5.0)
	draw_line(pos + Vector2(5.0, -13.0), pos + Vector2(7.0, -3.0), Color("#343445"), 5.0)
	# Colete de capanga e camisa listrada.
	draw_rect(Rect2(pos.x - 10.0, pos.y - 21.0, 20.0, 14.0), Color("#232c3b"))
	draw_rect(Rect2(pos.x - 4.0, pos.y - 20.0, 8.0, 13.0), Color("#ddc4a8"))
	for j in range(3):
		draw_line(Vector2(pos.x - 3.0, pos.y - 18.0 + float(j) * 4.0), Vector2(pos.x + 3.0, pos.y - 18.0 + float(j) * 4.0), Color("#7d5c57"), 1.0)
	draw_line(pos + Vector2(-9.0, -18.0), pos + Vector2(-15.0, -13.0), Color("#c79e7c"), 4.0)
	draw_line(pos + Vector2(9.0, -18.0), pos + Vector2(16.0, -14.0), Color("#c79e7c"), 4.0)
	# Cabeca, nariz, bigode e boina.
	draw_circle(pos + Vector2(0.0, -27.0), 8.0, Color("#c99373"))
	draw_circle(pos + Vector2(look * 5.0, -25.0), 2.5, Color("#d6a486"))
	draw_line(pos + Vector2(-5.0, -22.0), pos + Vector2(4.0, -22.0), Color("#302a31"), 3.0)
	draw_circle(pos + Vector2(look * 3.0, -28.0), 1.5, Color("#27222c"))
	draw_rect(Rect2(pos.x - 9.0, pos.y - 36.0, 18.0, 6.0), Color("#272634"))
	draw_rect(Rect2(pos.x - 11.0, pos.y - 32.0, 21.0, 3.0), Color("#272634"))
	if stunned:
		draw_circle(pos + Vector2(0.0, -24.0), 17.0, Color(0.37, 0.78, 0.90, 0.12))
		draw_arc(pos + Vector2(0.0, -24.0), 17.0, 0.0, TAU, 24, Color("#86d7e9"), 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(pos.x - 9.0, pos.y - 43.0), "ZZ", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#d1f7ff"))

func _draw_rolling_obstacle(center: Vector2) -> void:
	# Rolo giratorio de cenografia, sem violencia grafica.
	draw_circle(center + Vector2(1.0, 2.0), OBSTACLE_RADIUS + 1.0, Color("#352f3a"))
	draw_circle(center, OBSTACLE_RADIUS, Color("#bb6d52"))
	draw_circle(center, OBSTACLE_RADIUS - 4.0, Color("#dca475"))
	draw_circle(center, 5.0, Color("#66505a"))
	for i in range(4):
		var angle: float = hazard_clock * 3.0 + float(i) * PI * 0.5
		var spoke_end := center + Vector2(cos(angle), sin(angle)) * 10.0
		draw_line(center, spoke_end, Color("#6d4541"), 2.0)
	draw_circle(center, 2.0, Color("#efcb9b"))

func _draw_respawn_shield() -> void:
	# Escudo temporario apos dano ou retorno ao checkpoint.
	draw_arc(hero_pos + Vector2(0.0, -48.0), 31.0, 0.0, TAU, 32, Color(0.95, 0.84, 0.59, 0.42), 2.0)

func _draw_medal(world_pos: Vector2) -> void:
	# Medalha de latão cenografica, consistente com a arte retro do palco.
	draw_circle(world_pos + Vector2(1.0, 2.0), 10.0, Color("#49362f"))
	draw_circle(world_pos, 9.0, Color("#e4ac4f"))
	draw_circle(world_pos, 6.5, Color("#f6d47b"))
	draw_circle(world_pos, 4.2, Color("#d89d3d"))
	draw_string(ThemeDB.fallback_font, world_pos + Vector2(-5.5, 3.0), "CH", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#463332"))

func _draw_checkpoint() -> void:
	var mark: Vector2 = Stage.checkpoint()
	var pole_top := mark + Vector2(0.0, -78.0)
	draw_line(mark, pole_top, Color("#493d3c"), 5.0)
	draw_line(mark + Vector2(-7.0, 0.0), mark + Vector2(7.0, 0.0), Color("#c5a279"), 4.0)
	var flag_color := Color("#77bd85") if checkpoint_active else Color("#b47b60")
	draw_colored_polygon(PackedVector2Array([
		pole_top, pole_top + Vector2(45.0, 9.0),
		pole_top + Vector2(0.0, 26.0)
	]), flag_color)
	draw_string(ThemeDB.fallback_font, pole_top + Vector2(8.0, 17.0), "SAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

func _draw_exit_door() -> void:
	var door: Rect2 = Stage.exit_door()
	draw_rect(Rect2(door.position.x - 6.0, door.position.y - 9.0, door.size.x + 12.0, door.size.y + 9.0), Color("#624642"))
	draw_rect(door, Color("#332e42"))
	draw_rect(Rect2(door.position.x + 5.0, door.position.y + 6.0, door.size.x - 10.0, door.size.y - 6.0), Color("#86694e"))
	draw_rect(Rect2(door.position.x + 8.0, door.position.y + 10.0, door.size.x - 16.0, door.size.y - 10.0), Color("#4d4650"))
	draw_circle(door.position + Vector2(door.size.x - 13.0, door.size.y * 0.58), 3.0, Color("#f3cc86"))
	draw_rect(Rect2(door.position.x - 7.0, door.position.y - 23.0, door.size.x + 14.0, 14.0), Color("#dec093"))
	draw_string(ThemeDB.fallback_font, door.position + Vector2(4.0, -12.0), "SAIDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#46382f"))

func _draw_finish_screen() -> void:
	# Painel simples de conclusao; PULO serve para recomeçar a fase.
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color(0.06, 0.07, 0.10, 0.82))
	draw_rect(Rect2(92.0, 98.0, 456.0, 174.0), Color("#342b35"))
	draw_rect(Rect2(99.0, 105.0, 442.0, 160.0), Color("#57434a"))
	draw_string(ThemeDB.fallback_font, Vector2(157.0, 143.0), "FASE CONCLUIDA!", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("#f5d697"))
	var score_label := "MEDALHAS: %d / %d" % [finish_medals, medals.size()]
	draw_string(ThemeDB.fallback_font, Vector2(224.0, 187.0), score_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#f0e6ce"))
	var defeated_count: int = enemy_active.count(false)
	draw_string(ThemeDB.fallback_font, Vector2(211.0, 211.0), "INIMIGOS: %d / %d" % [defeated_count, enemy_active.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f0e6ce"))
	draw_string(ThemeDB.fallback_font, Vector2(231.0, 256.0), "SEGREDOS: %d / %d" % [secret_count, secret_rewards.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f5dbab"))
	draw_string(ThemeDB.fallback_font, Vector2(199.0, 235.0), "PRIMEIRO EPISODIO COMPLETO", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#e9c8a0"))
	# A tela cobre o HUD, entao o reinicio precisa ficar visivel.
	# A area coincide com o botao PULO, que continua acionando o reinicio.
	draw_rect(Rect2(509.0, 298.0, 120.0, 51.0), Color("#b78351"))
	draw_rect(Rect2(514.0, 302.0, 110.0, 43.0), Color("#634b40"))
	draw_string(ThemeDB.fallback_font, Vector2(519.0, 329.0), "REINICIAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func _draw_crate(block: Rect2) -> void:
	if city_set_art != null:
		# Caixa recortada da arte e dimensionada pela colisao real.
		draw_texture_rect_region(city_set_art,
			Rect2(block.position.x, block.position.y - 1.0, block.size.x, block.size.y + 2.0),
			Rect2(216.0, 230.0, 84.0, 59.0))
		return
	# Caixa cenografica original (fallback).
	draw_rect(block, Color("#5a3b31"))
	draw_rect(Rect2(block.position.x + 2.0, block.position.y + 2.0, block.size.x - 4.0, block.size.y - 4.0), Color("#a97851"))
	draw_rect(Rect2(block.position.x + 5.0, block.position.y + 5.0, block.size.x - 10.0, block.size.y - 10.0), Color("#c3976c"))
	draw_line(block.position + Vector2(5.0, 5.0), block.end - Vector2(5.0, 5.0), Color("#705040"), 3.0)
	draw_line(Vector2(block.end.x - 5.0, block.position.y + 5.0), Vector2(block.position.x + 5.0, block.end.y - 5.0), Color("#705040"), 3.0)
	draw_circle(block.position + Vector2(4.0, 4.0), 1.5, Color("#ead1a2"))
	draw_circle(block.end - Vector2(4.0, 4.0), 1.5, Color("#ead1a2"))

func _draw_rope(rope: Vector3) -> void:
	var top := Vector2(rope.x, rope.y)
	var end_point := Vector2(rope.x, rope.y + rope.z)
	if swinging and absf(rope_anchor.x - rope.x) < 1.0:
		end_point = rope_anchor + Vector2(sin(rope_angle), cos(rope_angle)) * rope_length
	# Cabo de cenario sustentado no teto, com cordame e no inferior.
	draw_line(Vector2(rope.x, 20.0), top, Color("#3f3235"), 2.0)
	draw_rect(Rect2(rope.x - 9.0, rope.y - 5.0, 18.0, 9.0), Color("#6d524b"))
	draw_circle(top, 4.0, Color("#e4be89"))
	draw_line(top, end_point, Color("#513e35"), 6.0)
	draw_line(top, end_point, Color("#d1aa78"), 3.0)
	var stripes := 9
	for i in range(1, stripes):
		var t := float(i) / float(stripes)
		var p := top.lerp(end_point, t)
		draw_circle(p, 2.4, Color("#e6c79f"))
	draw_circle(end_point, 5.0, Color("#8f6143"))
	if swinging and absf(rope_anchor.x - rope.x) < 1.0:
		var grip_point := rope_anchor + Vector2(sin(rope_angle), cos(rope_angle)) * rope_grip_distance
		draw_circle(grip_point, 4.0, Color("#f0cf9e"))
	if not swinging:
		draw_string(ThemeDB.fallback_font, Vector2(rope.x - 22.0, rope.y + 16.0), "CORDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#f0ce9e"))

func _draw_ladder(ladder: Rect2) -> void:
	if city_set_art != null:
		# Traves da escada recortadas e esticadas na altura funcional.
		draw_texture_rect_region(city_set_art,
			Rect2(ladder.position.x - 3.0, ladder.position.y - 3.0, ladder.size.x + 6.0, ladder.size.y + 3.0),
			Rect2(307.0, 128.0, 34.0, 159.0))
		return
	# Escada original (fallback).
	var left_x := ladder.position.x + 3.0
	var right_x := ladder.end.x - 3.0
	draw_line(Vector2(left_x, ladder.position.y - 6.0), Vector2(left_x, ladder.end.y), Color("#44332e"), 6.0)
	draw_line(Vector2(right_x, ladder.position.y - 6.0), Vector2(right_x, ladder.end.y), Color("#44332e"), 6.0)
	draw_line(Vector2(left_x, ladder.position.y - 6.0), Vector2(left_x, ladder.end.y), Color("#c39a70"), 3.0)
	draw_line(Vector2(right_x, ladder.position.y - 6.0), Vector2(right_x, ladder.end.y), Color("#c39a70"), 3.0)
	var rung_y := ladder.position.y + 5.0
	while rung_y < ladder.end.y:
		draw_line(Vector2(left_x, rung_y), Vector2(right_x, rung_y), Color("#533c35"), 5.0)
		draw_line(Vector2(left_x, rung_y - 1.0), Vector2(right_x, rung_y - 1.0), Color("#ecc49a"), 2.0)
		rung_y += 12.0

func _draw_low_beam(beam: Rect2) -> void:
	# Decorative hanging scenery plank with real gameplay collision.
	var mid_x := beam.position.x + beam.size.x / 2.0
	draw_line(Vector2(beam.position.x + 6.0, 111.0), Vector2(beam.position.x + 6.0, beam.position.y), Color("#d1b597"), 2.0)
	draw_line(Vector2(beam.end.x - 6.0, 111.0), Vector2(beam.end.x - 6.0, beam.position.y), Color("#d1b597"), 2.0)
	draw_rect(beam, Color("#553a34"))
	draw_rect(Rect2(beam.position.x + 3.0, beam.position.y + 3.0, beam.size.x - 6.0, beam.size.y - 7.0), Color("#b48c69"))
	draw_line(Vector2(beam.position.x, beam.end.y - 3.0), Vector2(beam.end.x, beam.end.y - 3.0), Color("#e1c393"), 3.0)
	draw_circle(Vector2(beam.position.x + 6.0, beam.position.y + 7.0), 2.0, Color("#e4cda6"))
	draw_circle(Vector2(beam.end.x - 6.0, beam.position.y + 7.0), 2.0, Color("#e4cda6"))
	draw_string(ThemeDB.fallback_font, Vector2(mid_x - 23.0, beam.position.y + 15.0), "AGACHE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#392d33"))

func _draw_rescue_npc() -> void:
	# Figurante presa perto da saida, com visual de cenario televisivo.
	var npc: Vector2 = Stage.rescue_npc()
	draw_circle(npc + Vector2(0.0, -76.0), 13.0, Color("#413443"))
	draw_circle(npc + Vector2(0.0, -75.0), 10.0, Color("#d6b18f"))
	draw_rect(Rect2(npc.x - 15.0, npc.y - 63.0, 30.0, 42.0), Color("#617988"))
	draw_rect(Rect2(npc.x - 11.0, npc.y - 59.0, 22.0, 38.0), Color("#86a0a0"))
	draw_line(npc + Vector2(-7.0, -24.0), npc + Vector2(-7.0, 0.0), Color("#342e42"), 6.0)
	draw_line(npc + Vector2(7.0, -24.0), npc + Vector2(7.0, 0.0), Color("#342e42"), 6.0)
	if rescue_complete:
		draw_line(npc + Vector2(13.0, -55.0), npc + Vector2(25.0, -81.0), Color("#d6b18f"), 5.0)
		draw_circle(npc + Vector2(25.0, -83.0), 4.0, Color("#d6b18f"))
	else:
		draw_line(npc + Vector2(-13.0, -55.0), npc + Vector2(-25.0, -37.0), Color("#d6b18f"), 5.0)
		draw_line(npc + Vector2(13.0, -55.0), npc + Vector2(23.0, -37.0), Color("#d6b18f"), 5.0)
	draw_string(ThemeDB.fallback_font, npc + Vector2(-30.0, -98.0), "SOCORRO!" if not rescue_complete else "OBRIGADA!", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f4d7b3"))

func _draw_story_portrait(speaker: String) -> void:
	var box_area := Rect2(72.0, 78.0, 122.0, 144.0)
	draw_rect(box_area, Color("#2e2834"))
	draw_rect(Rect2(77.0, 83.0, 112.0, 134.0), Color("#645663"))
	if speaker == "CHAPOLIN" and idle_texture != null:
		# Reutiliza um quadro do sprite aprovado, sem modificar o arquivo.
		var size := Vector2(float(idle_texture.get_width()) / 8.0, float(idle_texture.get_height()))
		draw_texture_rect_region(idle_texture, Rect2(90.0, 91.0, 83.0, 125.0), Rect2(0.0, 0.0, size.x, size.y), Color.WHITE, false, true)
	else:
		draw_circle(Vector2(133.0, 123.0), 22.0, Color("#413443"))
		draw_circle(Vector2(133.0, 126.0), 17.0, Color("#d6b18f"))
		draw_rect(Rect2(108.0, 145.0, 50.0, 65.0), Color("#78929a"))
		draw_rect(Rect2(120.0, 144.0, 26.0, 62.0), Color("#98aaa4"))

func _draw_story_scene() -> void:
	# Overlay da historia em 640x360; funciona sem novas texturas ou plugins.
	if story_step < 0 or story_step >= story_pages.size():
		return
	var page: Dictionary = story_pages[story_step]
	var speaker: String = String(page.get("speaker", ""))
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color(0.07, 0.06, 0.09, 0.90))
	draw_rect(Rect2(38.0, 29.0, 564.0, 310.0), Color("#302936"))
	draw_rect(Rect2(44.0, 35.0, 552.0, 298.0), Color("#594452"))
	draw_line(Vector2(45.0, 53.0), Vector2(595.0, 53.0), Color("#c6a57b"), 2.0)
	var scene_title := "PROLOGO: CIDADE DE PAPELAO"
	if story_scene_id == "checkpoint":
		scene_title = "NOVO ACONTECIMENTO"
	elif story_scene_id == "rescue":
		scene_title = "DESFECHO: RESGATE"
	draw_string(ThemeDB.fallback_font, Vector2(72.0, 63.0), scene_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f1d1a4"))
	_draw_story_portrait(speaker)
	draw_string(ThemeDB.fallback_font, Vector2(221.0, 109.0), speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#f6d69e"))
	draw_line(Vector2(220.0, 121.0), Vector2(554.0, 121.0), Color("#9f7c68"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(220.0, 157.0), String(page.get("line1", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(220.0, 181.0), String(page.get("line2", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(220.0, 216.0), "CENA %d/%d" % [story_step + 1, story_pages.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d8baa1"))
	draw_rect(STORY_SKIP_RECT, Color("#564957"))
	draw_rect(STORY_NEXT_RECT, Color("#94734d"))
	draw_string(ThemeDB.fallback_font, Vector2(80.0, 309.0), "PULAR CENA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	var continue_label := "CONTINUAR" if story_step + 1 >= story_pages.size() else "PROXIMO"
	draw_string(ThemeDB.fallback_font, Vector2(424.0, 309.0), continue_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func _draw_chapolin() -> void:
	var sprite: Texture2D = idle_texture
	if current_animation == "walk" and walk_texture != null:
		sprite = walk_texture
	elif current_animation == "run" and run_texture != null:
		sprite = run_texture
	elif (current_animation == "jump" or current_animation == "land" or current_animation == "crouch" or current_animation == "rope" or current_animation == "ledge" or current_animation == "ledge_climb") and jump_texture != null:
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
	elif current_animation == "crouch" and jump_texture != null:
		# Reuses the already-approved crouched preparation pose in the jump atlas.
		frame = 1
	elif (current_animation == "rope" or current_animation == "ledge") and jump_texture != null:
		# Reutiliza pose ja existente enquanto agarra corda ou borda.
		frame = 3
	elif current_animation == "ledge_climb" and jump_texture != null:
		frame = 2
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

func _draw_pause_inventory() -> void:
	# Inventario na mesma linguagem do HUD: painel editorial limpo e legivel.
	# Hitboxes dos botoes continuar e reiniciar permanecem inalteradas.
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color(0.025, 0.035, 0.07, 0.87))
	draw_rect(Rect2(88.0, 44.0, 464.0, 266.0), Color("#3a303e"))
	draw_rect(Rect2(94.0, 50.0, 452.0, 254.0), Color("#1c2234"))
	draw_rect(Rect2(94.0, 50.0, 452.0, 3.0), Color("#c99b65"))
	draw_string(ThemeDB.fallback_font, Vector2(119.0, 85.0), "JOGO PAUSADO", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f5d5a7"))
	draw_string(ThemeDB.fallback_font, Vector2(120.0, 105.0), "INVENTARIO E PROGRESSO", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#bfb0ac"))
	draw_rect(SOUND_TOGGLE_RECT, Color("#3c645b") if sound_enabled else Color("#514453"))
	draw_rect(Rect2(424.0, 69.0, 105.0, 28.0), Color("#293a41") if sound_enabled else Color("#342b3d"))
	draw_string(ThemeDB.fallback_font, Vector2(433.0, 89.0), "SOM: LIGADO" if sound_enabled else "SOM: MUDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c9ebd4") if sound_enabled else Color("#d7c0c5"))
	draw_line(Vector2(118.0, 113.0), Vector2(522.0, 113.0), Color("#564654"), 1.5)
	draw_line(Vector2(319.0, 127.0), Vector2(319.0, 234.0), Color("#564654"), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(121.0, 138.0), "EQUIPAMENTOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e1af79"))
	draw_string(ThemeDB.fallback_font, Vector2(341.0, 138.0), "PROGRESSO", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e1af79"))
	# Mesmo atlas de icones do gameplay, para continuidade visual.
	if _hud_v3_ready():
		_draw_hud_v3_icon(Vector2(109.0, 157.0), 9, 20.0, 1.0 if hammer_unlocked else 0.38)
		_draw_hud_v3_icon(Vector2(109.0, 185.0), 10, 20.0, 1.0 if horn_unlocked else 0.38)
		_draw_hud_v3_icon(Vector2(109.0, 213.0), 11, 20.0, 1.0 if nano_unlocked else 0.38)
		_draw_hud_v3_icon(Vector2(329.0, 158.0), 4, 20.0)
		_draw_hud_v3_icon(Vector2(329.0, 183.0), 5, 20.0, 0.75)
		_draw_hud_v3_icon(Vector2(329.0, 208.0), 3, 20.0)
	else:
		_draw_hud_icon(Vector2(109.0, 157.0), "hammer", 17.0, 1.0 if hammer_unlocked else 0.38)
		_draw_hud_icon(Vector2(109.0, 185.0), "horn", 17.0, 1.0 if horn_unlocked else 0.38)
		_draw_hud_icon(Vector2(109.0, 213.0), "nano", 17.0, 1.0 if nano_unlocked else 0.38)
		_draw_hud_icon(Vector2(329.0, 158.0), "medal", 19.0)
		_draw_hud_icon(Vector2(329.0, 183.0), "medal", 17.0, 0.72)
		_draw_hud_icon(Vector2(329.0, 208.0), "hero", 18.0)
	var normal_color := Color("#f1e4d2")
	var collected_color := Color("#a9d8b4") if hammer_unlocked else Color("#9a8b98")
	draw_string(ThemeDB.fallback_font, Vector2(121.0, 166.0), "MARRETA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, normal_color)
	draw_string(ThemeDB.fallback_font, Vector2(255.0, 166.0), "OK" if hammer_unlocked else "--", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, collected_color)
	draw_string(ThemeDB.fallback_font, Vector2(121.0, 194.0), "CORNETA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, normal_color)
	draw_string(ThemeDB.fallback_font, Vector2(244.0, 194.0), "%d CARGAS" % horn_charges, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#add8df") if horn_unlocked else Color("#9a8b98"))
	draw_string(ThemeDB.fallback_font, Vector2(121.0, 222.0), "NANICOLINA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, normal_color)
	draw_string(ThemeDB.fallback_font, Vector2(248.0, 222.0), "%d USOS" % nano_charges, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#b8dcb2") if nano_unlocked else Color("#9a8b98"))

	draw_string(ThemeDB.fallback_font, Vector2(341.0, 165.0), "MEDALHAS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, normal_color)
	draw_string(ThemeDB.fallback_font, Vector2(467.0, 165.0), "%d/%d" % [medal_count, medals.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#efd18f"))
	draw_string(ThemeDB.fallback_font, Vector2(341.0, 189.0), "SEGREDOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, normal_color)
	draw_string(ThemeDB.fallback_font, Vector2(467.0, 189.0), "%d/%d" % [secret_count, secret_rewards.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#efd18f"))
	draw_string(ThemeDB.fallback_font, Vector2(341.0, 213.0), "VIDAS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, normal_color)
	draw_string(ThemeDB.fallback_font, Vector2(480.0, 213.0), "%d" % lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f0dcb9"))
	draw_string(ThemeDB.fallback_font, Vector2(341.0, 237.0), "CHECKPOINT " + ("SALVO" if checkpoint_active else "INICIAL"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a4d5b0") if checkpoint_active else Color("#c7b6b5"))

	draw_rect(Rect2(140.0, 251.0, 166.0, 43.0), Color("#365e56"))
	draw_rect(Rect2(144.0, 255.0, 158.0, 35.0), Color("#427a65"))
	draw_rect(Rect2(332.0, 251.0, 166.0, 43.0), Color("#755149"))
	draw_rect(Rect2(336.0, 255.0, 158.0, 35.0), Color("#945e50"))
	draw_string(ThemeDB.fallback_font, Vector2(178.0, 279.0), "CONTINUAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f8eedf"))
	draw_string(ThemeDB.fallback_font, Vector2(355.0, 279.0), "REINICIAR FASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f8eedf"))
	draw_string(ThemeDB.fallback_font, Vector2(385.0, 302.0), "BUILD " + installed_build, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ab9ca4"))

func _draw_lever(index: int) -> void:
	var lever: Vector3 = lever_points[index]
	var base := Vector2(lever.x, lever.y)
	var activated: bool = lever_states[index]
	# Pedestal de metal da cenografia e cabo colorido.
	draw_rect(Rect2(base.x - 12.0, base.y - 6.0, 24.0, 6.0), Color("#49353b"))
	draw_rect(Rect2(base.x - 8.0, base.y - 27.0, 16.0, 22.0), Color("#776269"))
	draw_rect(Rect2(base.x - 5.0, base.y - 24.0, 10.0, 15.0), Color("#b2a29b"))
	var handle_direction: float = 1.0 if activated else -1.0
	draw_line(base + Vector2(0.0, -24.0), base + Vector2(handle_direction * 14.0, -43.0), Color("#c2a58a"), 4.0)
	draw_circle(base + Vector2(handle_direction * 14.0, -43.0), 6.0, Color("#70ba7c") if activated else Color("#e3a960"))
	var name: String = "GRADE" if index == 0 else "PLATAFORMA"
	draw_string(ThemeDB.fallback_font, base + Vector2(-27.0, -53.0), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#e9d1ad"))
	var status_color := Color("#7fc38d") if activated else Color("#d6aa75")
	draw_circle(base + Vector2(0.0, -16.0), 3.0, status_color)

func _draw_lever_gate() -> void:
	var gate: Rect2 = lever_gate
	var opened: bool = _lever_gate_open()
	# Estrutura permanece visivel mesmo apos abrir.
	draw_rect(Rect2(gate.position.x - 4.0, gate.position.y - 5.0, gate.size.x + 8.0, gate.size.y + 5.0), Color("#493a42"), false, 3.0)
	if opened:
		draw_rect(Rect2(gate.position.x + 4.0, gate.position.y - 4.0, gate.size.x - 8.0, 6.0), Color("#82be92"))
		draw_string(ThemeDB.fallback_font, Vector2(gate.position.x - 13.0, gate.position.y - 13.0), "ON", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#9cd7a4"))
	else:
		draw_rect(gate, Color("#534850"))
		draw_rect(Rect2(gate.position.x + 4.0, gate.position.y, gate.size.x - 8.0, gate.size.y), Color("#b27f60"))
		for i in range(6):
			var y: float = gate.position.y + 15.0 + float(i) * 24.0
			draw_line(Vector2(gate.position.x + 1.0, y), Vector2(gate.end.x - 1.0, y), Color("#e3bf8c"), 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(gate.position.x - 13.0, gate.position.y - 13.0), "OFF", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#e6a879"))

func _draw_moving_platform(platform: Rect2, spec: Dictionary, powered: bool) -> void:
	# Trilho de estúdio com uma plataforma deslizante de madeira e ferro.
	var min_center: float = float(spec["min_x"]) + platform.size.x * 0.5
	var max_center: float = float(spec["max_x"]) + platform.size.x * 0.5
	var rail_y: float = platform.position.y - 29.0
	draw_line(Vector2(min_center, rail_y), Vector2(max_center, rail_y), Color("#4a4145"), 5.0)
	draw_line(Vector2(min_center, rail_y - 2.0), Vector2(max_center, rail_y - 2.0), Color("#b9a082"), 2.0)
	var center_x: float = platform.position.x + platform.size.x * 0.5
	draw_line(Vector2(center_x, rail_y), Vector2(center_x, platform.position.y), Color("#b9a082"), 3.0)
	draw_rect(platform, Color("#443841"))
	draw_rect(Rect2(platform.position.x + 3.0, platform.position.y + 2.0, platform.size.x - 6.0, platform.size.y - 5.0), Color("#ad7a58"))
	draw_line(platform.position + Vector2(3.0, 2.0), Vector2(platform.end.x - 3.0, platform.position.y + 2.0), Color("#e5bf8b"), 2.0)
	for i in range(3):
		var bolt_x: float = platform.position.x + 10.0 + float(i) * (platform.size.x - 20.0) / 2.0
		draw_circle(Vector2(bolt_x, platform.position.y + 8.0), 1.5, Color("#564449"))
	# Luz informa de imediato se a plataforma esta ligada ou aguardando alavanca.
	draw_circle(Vector2(center_x, rail_y), 5.0, Color("#7ac88f") if powered else Color("#c77b68"))
	if not powered:
		draw_string(ThemeDB.fallback_font, Vector2(center_x - 12.0, rail_y - 12.0), "OFF", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#e4ac91"))

func _draw_ledge_grab_markers() -> void:
	# Pequenas marcacoes douradas mostram em quais cantos e possivel agarrar.
	for grip in ledge_grab_points:
		var corner := Vector2(grip.x, grip.y)
		var side: float = float(int(grip.z))
		draw_line(corner, corner + Vector2(side * 15.0, 0.0), Color("#eac58d"), 3.0)
		draw_circle(corner + Vector2(side * 5.0, -2.0), 2.0, Color("#f8e1ae"))

func _draw_ledge_grip() -> void:
	# Marcador discreto do ponto onde as maos seguram o canto.
	draw_circle(ledge_edge, 4.0, Color("#f3d5a4"))
	draw_line(ledge_edge + Vector2(-6.0, 0.0), ledge_edge + Vector2(6.0, 0.0), Color("#f3d5a4"), 2.0)

func _draw_health_hud() -> void:
	# Coracoes e contador compactos no setor de resistencia da barra.
	for i in range(MAX_HEALTH):
		var x: float = 353.0 + float(i) * 25.0
		var y: float = 5.0
		var fill: Color = Color("#f15f66") if i < health else Color("#443745")
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, y + 6.0), Vector2(x + 3.0, y + 2.0),
			Vector2(x + 7.0, y + 2.0), Vector2(x + 10.0, y + 5.0),
			Vector2(x + 13.0, y + 2.0), Vector2(x + 17.0, y + 2.0),
			Vector2(x + 20.0, y + 6.0), Vector2(x + 20.0, y + 11.0),
			Vector2(x + 10.0, y + 21.0), Vector2(x, y + 11.0)
		]), fill)
		if i < health:
			draw_line(Vector2(x + 4.0, y + 5.0), Vector2(x + 8.0, y + 4.0), Color("#ffbdb5"), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(359.0, 40.0), "VIDAS x%02d" % lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f3e0c9"))

func _draw_game_over() -> void:
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color(0.07, 0.06, 0.10, 0.87))
	draw_rect(Rect2(112.0, 95.0, 416.0, 180.0), Color("#372c38"))
	draw_rect(Rect2(120.0, 103.0, 400.0, 164.0), Color("#65454b"))
	draw_string(ThemeDB.fallback_font, Vector2(196.0, 150.0), "FIM DE JOGO", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("#f1d09b"))
	draw_string(ThemeDB.fallback_font, Vector2(174.0, 190.0), "O CHAPOLIN TENTA NOVAMENTE!", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f4e5cc"))
	draw_string(ThemeDB.fallback_font, Vector2(206.0, 230.0), "APERTE PULO PARA REINICIAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f4d8b0"))
	# Coincide com a area real do botao PULO no celular.
	draw_rect(Rect2(509.0, 298.0, 120.0, 51.0), Color("#b78351"))
	draw_rect(Rect2(514.0, 302.0, 110.0, 43.0), Color("#634b40"))
	draw_string(ThemeDB.fallback_font, Vector2(519.0, 329.0), "REINICIAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func _hud_icon_index(kind: String) -> int:
	match kind:
		"hero":
			return 0
		"hammer":
			return 1
		"horn":
			return 2
		"jump":
			return 3
		"nano":
			return 4
		"lever":
			return 5
		"medal":
			return 6
		"pause":
			return 7
	return -1

func _draw_hud_icon(center: Vector2, kind: String, size: float, opacity: float = 1.0) -> void:
	var index: int = _hud_icon_index(kind)
	if index >= 0 and hud_icons != null:
		var dest: Rect2 = Rect2(center - Vector2(size, size) * 0.5, Vector2(size, size))
		var source: Rect2 = Rect2(float(index) * 48.0, 0.0, 48.0, 48.0)
		draw_texture_rect_region(hud_icons, dest, source, Color(1.0, 1.0, 1.0, opacity))
		return
	# Fallback garantido: vetor legivel mesmo sem importar o atlas SVG.
	var color: Color = Color(1.0, 0.91, 0.74, opacity)
	match kind:
		"hammer":
			draw_line(center + Vector2(-8.0, 10.0), center + Vector2(5.0, -9.0), color, 4.0)
			draw_line(center + Vector2(-2.0, -12.0), center + Vector2(11.0, -2.0), color, 8.0)
		"horn":
			draw_line(center + Vector2(-11.0, 0.0), center + Vector2(-2.0, 0.0), color, 4.0)
			draw_colored_polygon(PackedVector2Array([center + Vector2(-2.0, -5.0), center + Vector2(11.0, -12.0), center + Vector2(11.0, 10.0), center + Vector2(-2.0, 5.0)]), color)
		"jump":
			draw_line(center + Vector2(-10.0, 4.0), center + Vector2(0.0, -9.0), color, 5.0)
			draw_line(center + Vector2(0.0, -9.0), center + Vector2(10.0, 4.0), color, 5.0)
		"nano":
			draw_rect(Rect2(center.x - 6.0, center.y - 9.0, 12.0, 19.0), color)
			draw_rect(Rect2(center.x - 3.0, center.y - 5.0, 6.0, 8.0), Color("#4b9d84"))
		"lever":
			draw_line(center + Vector2(-9.0, 7.0), center + Vector2(9.0, 7.0), color, 3.0)
			draw_line(center + Vector2(-1.0, 7.0), center + Vector2(7.0, -10.0), color, 4.0)
			draw_circle(center + Vector2(7.0, -10.0), 4.0, Color("#e9b16d"))
		"medal":
			draw_circle(center, size * 0.42, Color("#c59759"))
			draw_circle(center, size * 0.33, Color("#f4da94"))
		"pause":
			draw_rect(Rect2(center.x - 8.0, center.y - 11.0, 6.0, 22.0), color)
			draw_rect(Rect2(center.x + 2.0, center.y - 11.0, 6.0, 22.0), color)
		_:
			draw_circle(center, size * 0.33, color)

func _draw_hud_action(center: Vector2, radius: float, kind: String, label: String, available: bool, accent: Color, recharge: float = 0.0) -> void:
	# Botoes profissionais de dois materiais: aro metalico + miolo translúcido.
	# Toda a area de toque original permanece idêntica.
	var edge_color: Color = accent if available else Color("#6d6d7c")
	draw_circle(center + Vector2(0.0, 2.0), radius + 3.0, Color(0.02, 0.03, 0.07, 0.66))
	draw_circle(center, radius + 1.0, Color(0.40, 0.33, 0.39, 0.70 if available else 0.34))
	draw_circle(center, radius - 2.0, Color(0.095, 0.115, 0.18, 0.87 if available else 0.59))
	draw_arc(center, radius, 0.0, TAU, 40, Color(edge_color.r, edge_color.g, edge_color.b, 0.91 if available else 0.33), 2.0)
	draw_arc(center, radius - 4.5, PI * 1.12, PI * 1.82, 16, Color(1.0, 0.95, 0.77, 0.25 if available else 0.11), 1.0)
	var icon_size: float = 28.0 if radius > 25.0 else (25.0 if radius > 21.0 else 20.0)
	_draw_hud_icon(center + Vector2(0.0, -7.0), kind, icon_size, 1.0 if available else 0.44)
	var small_size: int = 9 if radius > 21.0 else 8
	var label_x: float = center.x - float(label.length()) * float(small_size) * 0.275
	draw_string(ThemeDB.fallback_font, Vector2(label_x, center.y + radius - 6.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, small_size, Color("#ffeccd") if available else Color("#8d8b95"))
	if recharge > 0.0 and available:
		var progress: float = 1.0 - clampf(recharge, 0.0, 1.0)
		draw_arc(center, radius + 2.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 28, Color("#efdaa5"), 2.3)

func _draw_hud_count(center: Vector2, quantity: int) -> void:
	draw_circle(center, 9.0, Color("#302b3e"))
	draw_arc(center, 9.0, 0.0, TAU, 20, Color("#cfaa75"), 1.3)
	draw_string(ThemeDB.fallback_font, center + Vector2(-3.0 if quantity < 10 else -6.0, 4.0), "%d" % quantity, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#fff2d8"))

func _hud_v3_ready() -> bool:
	return hud_v3_bar != null and hud_v3_icons != null and hud_v3_controls != null

func _draw_hud_v3_icon(center: Vector2, index: int, diameter: float, opacity: float = 1.0) -> void:
	# Icones de 112x112 em grade 4x4, todos extraidos da arte aprovada.
	if hud_v3_icons == null:
		return
	var column: int = index % 4
	var row: int = int(floor(float(index) / 4.0))
	var region := Rect2(float(column) * 112.0, float(row) * 112.0, 112.0, 112.0)
	var dest := Rect2(center - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter)
	draw_texture_rect_region(hud_v3_icons, dest, region, Color(1.0, 1.0, 1.0, opacity))

func _draw_hud_v3_control(center: Vector2, index: int, diameter: float, opacity: float = 1.0) -> void:
	# Joystick, PULO, USAR, CORRER e aneis em grade 3x2 de 136px.
	if hud_v3_controls == null:
		return
	var column: int = index % 3
	var row: int = int(floor(float(index) / 3.0))
	var region := Rect2(float(column) * 136.0, float(row) * 136.0, 136.0, 136.0)
	var dest := Rect2(center - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter)
	draw_texture_rect_region(hud_v3_controls, dest, region, Color(1.0, 1.0, 1.0, opacity))

func _draw_hud_v3_tool(center: Vector2, icon_index: int, enabled: bool, progress: float = 0.0) -> void:
	# As ferramentas sao menores que os comandos principais e nunca invadem a
	# area do joystick. Mantem todas as habilidades existentes no jogo.
	var alpha: float = 0.88 if enabled else 0.36
	_draw_hud_v3_control(center, 5, 47.0, alpha)
	_draw_hud_v3_icon(center, icon_index, 37.0, 1.0 if enabled else 0.32)
	if progress > 0.0 and enabled:
		draw_arc(center, 24.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - clampf(progress, 0.0, 1.0)), 24, Color("#eec98c"), 2.0)

func _hud_v3_moved_crates() -> int:
	# O contador de caixas acompanha deslocamentos reais e salvos.
	var initial: Array[Rect2] = Stage.crates()
	var moved := 0
	for i in range(mini(initial.size(), crates.size())):
		if absf(crates[i].position.x - initial[i].position.x) > 4.0:
			moved += 1
	return moved

func _draw_controls_v3() -> void:
	# Joystick com referencia visual permanente. O toque real continua
	# flutuante, sem exigir que o dedo comece no centro do anel.
	var base: Vector2 = Vector2(80.0, 296.0) if joystick_touch_id == -1 else joystick_origin
	_draw_hud_v3_control(base, 0, 108.0, 0.48 if joystick_touch_id == -1 else 0.78)
	if joystick_touch_id != -1:
		var knob: Vector2 = base + joystick_offset
		_draw_hud_v3_control(knob, 1, 43.0, 0.94)

	# Ferramentas especiais ocupam uma faixa secundaria; nenhum botao
	# sobrepoe as hitboxes de PULO, USAR ou CORRER.
	_draw_hud_v3_tool(Vector2(354.0, 327.0), 9, hammer_unlocked, hammer_cooldown / HAMMER_COOLDOWN)
	_draw_hud_v3_tool(Vector2(414.0, 327.0), 10, horn_unlocked and horn_charges > 0, horn_cooldown / HORN_COOLDOWN)
	_draw_hud_v3_tool(Vector2(466.0, 260.0), 11, nano_unlocked and (nano_charges > 0 or _nano_active()))
	if horn_unlocked:
		draw_string(ThemeDB.fallback_font, Vector2(431.0, 309.0), "%d" % horn_charges, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f6dfb6"))
	if nano_unlocked:
		draw_string(ThemeDB.fallback_font, Vector2(482.0, 242.0), "%d" % nano_charges, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#d0e3c1"))
	if _nano_active():
		var fraction: float = clampf(nano_remaining / NANO_DURATION, 0.0, 1.0)
		draw_arc(Vector2(466.0, 260.0), 23.0, -PI * 0.5, -PI * 0.5 + TAU * fraction, 28, Color("#9ff1bb"), 2.5)

	# Controles identicos a arte de referencia: PULO e USAR na base,
	# CORRER logo acima. USAR so funciona junto a alavanca valida.
	var can_interact: bool = _nearby_lever_index() >= 0 and not pause_menu_open and not stage_complete and not game_over
	_draw_hud_v3_control(Vector2(508.0, 323.0), 3, 59.0, 0.91 if can_interact else 0.40)
	_draw_hud_v3_control(Vector2(585.0, 323.0), 2, 73.0, 0.94)
	_draw_hud_v3_control(Vector2(588.0, 244.0), 4, 62.0 if run_touch_id != -1 else 59.0, 0.97 if run_touch_id != -1 else 0.73)
	if can_interact:
		draw_rect(Rect2(484.0, 282.0, 48.0, 16.0), Color(0.10, 0.09, 0.16, 0.78))
		draw_string(ThemeDB.fallback_font, Vector2(492.0, 294.0), "USAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f6d6a7"))

	# HUD superior: a arte aprovada recebe apenas textos e numeros dinamicos.
	draw_texture_rect(hud_v3_bar, Rect2(0.0, 0.0, 640.0, 64.0), false)
	draw_string(ThemeDB.fallback_font, Vector2(144.0, 18.0), "PRÓLOGO", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#dfa96b"))
	draw_string(ThemeDB.fallback_font, Vector2(143.0, 32.0), "CIDADE DE PAPELÃO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#fff0da"))
	var objective: String = "EMPURRE A CAIXA"
	if puzzle_gate_open and not checkpoint_active:
		objective = "SIGA AO CHECKPOINT"
	elif checkpoint_active and (lever_states.is_empty() or not lever_states[0]):
		objective = "ENCONTRE A ALAVANCA"
	elif lever_states.size() > 1 and not lever_states[1]:
		objective = "LIGUE A PLATAFORMA"
	elif lever_states.size() > 1 and lever_states[1]:
		objective = "RESGATE A MORADORA"
	if stage_complete:
		objective = "RESGATE CONCLUIDO"
	draw_string(ThemeDB.fallback_font, Vector2(145.0, 49.0), objective, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#f7d6aa"))

	# Coracoes reais (sem coracoes falsamente preenchidos no fundo).
	for i in range(MAX_HEALTH):
		_draw_hud_v3_icon(Vector2(326.0 + float(i) * 24.0, 31.0), 0 if i < health else 2, 25.0)
	_draw_hud_v3_icon(Vector2(425.0, 31.0), 3, 45.0)
	draw_string(ThemeDB.fallback_font, Vector2(439.0, 48.0), "x%02d" % lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#fff1d5"))
	draw_string(ThemeDB.fallback_font, Vector2(501.0, 42.0), "x%03d" % medal_count, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#fff1d5"))
	draw_string(ThemeDB.fallback_font, Vector2(601.0, 43.0), "%d/%d" % [_hud_v3_moved_crates(), crates.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#fff1d5"))
	# Pausa discreta no canto: nao se sobrepoe ao contador das caixas.
	_draw_hud_v3_icon(Vector2(623.0, 13.0), 13, 19.0, 0.94)

	if ledge_hanging:
		draw_rect(Rect2(178.0, 68.0, 276.0, 22.0), Color(0.05, 0.07, 0.12, 0.80))
		draw_string(ThemeDB.fallback_font, Vector2(190.0, 83.0), "CIMA: SUBIR   BAIXO: SOLTAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ffe4b4"))
	if save_notice_time > 0.0 and not pause_menu_open:
		draw_rect(Rect2(570.0, 68.0, 60.0, 17.0), Color(0.07, 0.19, 0.14, 0.85))
		draw_string(ThemeDB.fallback_font, Vector2(579.0, 81.0), "SALVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#b3dfb4"))

func _draw_controls() -> void:
	# Um unico caminho de desenho: HUD premium OU fallback — nunca ambas.
	if _hud_v3_ready():
		_draw_controls_v3()
	else:
		_draw_controls_legacy()

func _draw_controls_legacy() -> void:
	# Apenas reserva de compatibilidade quando faltar alguma arte da HUD v3.
	# Joystick invisivel ate o dedo esquerdo encostar, preservando multitouch.
	if joystick_touch_id != -1:
		draw_circle(joystick_origin, JOYSTICK_RADIUS + 2.0, Color(0.08, 0.10, 0.17, 0.36))
		draw_arc(joystick_origin, JOYSTICK_RADIUS, 0.0, TAU, 42, Color(0.91, 0.82, 0.70, 0.56), 2.0)
		var knob: Vector2 = joystick_origin + joystick_offset
		draw_circle(knob, 22.0, Color(0.19, 0.25, 0.34, 0.83))
		draw_arc(knob, 22.0, 0.0, TAU, 32, Color(0.85, 0.85, 0.87, 0.76), 2.0)
		draw_circle(knob, 6.0, Color("#eee1c9"))
		for i in range(4):
			var angle: float = float(i) * PI * 0.5
			var dir: Vector2 = Vector2(cos(angle), sin(angle))
			var point: Vector2 = joystick_origin + dir * 38.0
			draw_line(point - dir * 5.0, point, Color(0.91, 0.89, 0.81, 0.62), 2.0)

	# Botoes de acao — alinhados exatamente com as hitboxes já aprovadas.
	_draw_hud_action(Vector2(376.0, 329.0), 27.0, "hammer", "MARRETA", hammer_unlocked, Color("#d9a06c"), hammer_cooldown / HAMMER_COOLDOWN)
	_draw_hud_action(Vector2(479.0, 329.0), 27.0, "horn", "CORNETA", horn_unlocked and horn_charges > 0, Color("#91c9d8"), horn_cooldown / HORN_COOLDOWN)
	_draw_hud_action(Vector2(585.0, 330.0), 29.0, "jump", "PULO", true, Color("#f3d9ad"))
	var nano_ready: bool = nano_unlocked and (nano_charges > 0 or _nano_active())
	_draw_hud_action(Vector2(585.0, 276.0), 19.0, "nano", "NANO", nano_ready, Color("#9ccd9f"))
	if horn_unlocked:
		_draw_hud_count(Vector2(500.0, 298.0), horn_charges)
	if nano_unlocked:
		_draw_hud_count(Vector2(609.0, 262.0), nano_charges)
	if _nano_active():
		var time_left: float = clampf(nano_remaining / NANO_DURATION, 0.0, 1.0)
		draw_arc(Vector2(585.0, 276.0), 21.0, -PI * 0.5, -PI * 0.5 + TAU * time_left, 32, Color("#a7edb9"), 2.5)

	# Topo de 48px: escudo / fase e objetivo / HP / medalhas / pausa.
	draw_rect(Rect2(0.0, 0.0, 640.0, 48.0), Color(0.05, 0.06, 0.11, 0.95))
	draw_rect(Rect2(0.0, 0.0, 640.0, 2.0), Color("#b98859"))
	draw_rect(Rect2(0.0, 46.0, 640.0, 2.0), Color("#5d4b60"))
	for divider_x in [112.0, 346.0, 448.0, 565.0]:
		draw_line(Vector2(divider_x, 8.0), Vector2(divider_x, 41.0), Color("#6a5266"), 1.0)
	_draw_hud_icon(Vector2(22.0, 24.0), "hero", 33.0)
	draw_string(ThemeDB.fallback_font, Vector2(41.0, 23.0), "CHAPOLIN", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#ffe2aa"))
	draw_string(ThemeDB.fallback_font, Vector2(43.0, 37.0), "ADVENTURES", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#d79978"))
	draw_string(ThemeDB.fallback_font, Vector2(123.0, 20.0), "CIDADE DE PAPELAO", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f8e9d3"))
	var objective: String = "EMPURRE A CAIXA"
	if puzzle_gate_open and not checkpoint_active:
		objective = "SIGA AO CHECKPOINT"
	elif checkpoint_active and (lever_states.is_empty() or not lever_states[0]):
		objective = "ENCONTRE A ALAVANCA"
	elif lever_states.size() > 1 and not lever_states[1]:
		objective = "LIGUE A PLATAFORMA"
	elif lever_states.size() > 1 and lever_states[1]:
		objective = "RESGATE A MORADORA"
	if stage_complete:
		objective = "RESGATE CONCLUIDO"
	draw_circle(Vector2(126.0, 33.0), 2.0, Color("#e0ad73"))
	draw_string(ThemeDB.fallback_font, Vector2(134.0, 37.0), objective, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#cbbfb6"))

	_draw_health_hud()
	draw_line(Vector2(354.0, 43.5), Vector2(437.0, 43.5), Color("#5c4e5d"), 1.0)
	_draw_hud_icon(Vector2(466.0, 24.0), "medal", 29.0)
	draw_string(ThemeDB.fallback_font, Vector2(483.0, 26.0), "%02d/%02d" % [medal_count, medals.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f6e3bc"))
	draw_string(ThemeDB.fallback_font, Vector2(486.0, 40.0), "MEDALHAS", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#bda8a2"))
	draw_circle(Vector2(600.0, 24.0), 19.0, Color("#292a3b"))
	draw_arc(Vector2(600.0, 24.0), 19.0, 0.0, TAU, 36, Color("#c7a77d"), 1.5)
	_draw_hud_icon(Vector2(600.0, 24.0), "pause", 27.0)

	# Interacoes contextuais aparecem so perto da acao correspondente.
	if ledge_hanging:
		draw_rect(Rect2(180.0, 62.0, 265.0, 23.0), Color(0.07, 0.08, 0.15, 0.83))
		draw_string(ThemeDB.fallback_font, Vector2(193.0, 78.0), "CIMA: SUBIR   BAIXO: SOLTAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f5d7a0"))
	var lever_index: int = _nearby_lever_index()
	if lever_index >= 0 and not pause_menu_open and not stage_complete and not game_over:
		_draw_hud_action(Vector2(580.0, 229.0), 20.0, "lever", "USAR", true, Color("#e1b56c"))
	if save_notice_time > 0.0 and not pause_menu_open:
		draw_rect(Rect2(570.0, 57.0, 58.0, 18.0), Color(0.09, 0.20, 0.15, 0.84))
		draw_string(ThemeDB.fallback_font, Vector2(580.0, 70.0), "SALVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#b3dfb4"))

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if title_active and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE):
				_begin_from_title(not title_has_save)
				return
			if key_event.keycode == KEY_E:
				_activate_nearby_lever()
	# Android editor can deliver touch events or mouse events emulated from touch.
	# Both are mapped into the Node2D canvas coordinate space.
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = make_input_local(event) as InputEventScreenTouch
		if touch_event.pressed:
			_pointer_pressed(touch_event.position, touch_event.index)
		else:
			_pointer_released(touch_event.index)
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = make_input_local(event) as InputEventScreenDrag
		_pointer_moved(drag_event.position, drag_event.index)
	elif event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		var mouse_event: InputEventMouseButton = make_input_local(event) as InputEventMouseButton
		if mouse_event.pressed:
			_pointer_pressed(mouse_event.position, MOUSE_POINTER_ID)
		else:
			_pointer_released(MOUSE_POINTER_ID)
	elif event is InputEventMouseMotion:
		# Do not turn a mere cursor hover into movement.
		if joystick_touch_id == MOUSE_POINTER_ID and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			var motion_event: InputEventMouseMotion = make_input_local(event) as InputEventMouseMotion
			_pointer_moved(motion_event.position, MOUSE_POINTER_ID)

func _pointer_pressed(pos: Vector2, pointer_id: int) -> void:
	if title_active:
		if TITLE_PLAY_RECT.has_point(pos):
			_begin_from_title(not title_has_save)
		elif TITLE_NEW_RECT.has_point(pos):
			_begin_from_title(true)
		return
	if story_active:
		if STORY_SKIP_RECT.has_point(pos):
			_finish_story()
		elif STORY_NEXT_RECT.has_point(pos):
			_advance_story()
		queue_redraw()
		return
	if (stage_complete or game_over) and Rect2(509.0, 298.0, 120.0, 51.0).has_point(pos):
		jump_requested = true
		return
	if pause_menu_open:
		if SOUND_TOGGLE_RECT.has_point(pos):
			sound_enabled = not sound_enabled
			_save_game()
		elif Rect2(140.0, 251.0, 166.0, 43.0).has_point(pos):
			pause_menu_open = false
		elif Rect2(332.0, 251.0, 166.0, 43.0).has_point(pos):
			_restart_stage()
		queue_redraw()
		return
	if not stage_complete and not game_over and (HUD_V3_PAUSE_RECT.has_point(pos) if _hud_v3_ready() else HUD_PAUSE_RECT.has_point(pos)):
		pause_menu_open = true
		run_touch_id = -1
		_release_joystick()
		jump_requested = false
		_save_game()
		queue_redraw()
		return
	# HUD v3: botoes com hitboxes proprias, sem sobreposicao.
	# O desenho e as areas de toque vem da mesma especificacao.
	if _hud_v3_ready():
		if HUD_V3_RUN_RECT.has_point(pos):
			if run_touch_id == -1:
				run_touch_id = pointer_id
				queue_redraw()
			return
		if HUD_V3_JUMP_RECT.has_point(pos):
			jump_requested = true
			return
		if HUD_V3_USE_RECT.has_point(pos):
			if _nearby_lever_index() >= 0:
				_activate_nearby_lever()
			return
		if HUD_V3_NANO_RECT.has_point(pos):
			_use_nano()
			return
		if HUD_V3_HORN_RECT.has_point(pos):
			_use_horn()
			return
		if HUD_V3_HAMMER_RECT.has_point(pos):
			_use_hammer()
			return
		if joystick_touch_id == -1 and pos.x >= 0.0 and pos.x <= 320.0 and pos.y >= 90.0 and pos.y <= 360.0:
			joystick_touch_id = pointer_id
			joystick_origin = pos
			joystick_offset = Vector2.ZERO
			_update_joystick_axes()
			queue_redraw()
		return

	# Botao contextual de alavanca, sem mexer nos ataques e no joystick.
	if Rect2(535.0, 208.0, 90.0, 44.0).has_point(pos) and _nearby_lever_index() >= 0:
		_activate_nearby_lever()
		return
	# The left half is an invisible floating joystick activation zone.
	if joystick_touch_id == -1 and pos.x >= 0.0 and pos.x <= 320.0 and pos.y >= 90.0 and pos.y <= 360.0:
		joystick_touch_id = pointer_id
		joystick_origin = pos
		joystick_offset = Vector2.ZERO
		_update_joystick_axes()
		queue_redraw()
	elif pos.x >= 326.0 and pos.x <= 426.0 and pos.y >= 295.0 and pos.y <= 360.0:
		_use_hammer()
	elif pos.x >= 429.0 and pos.x <= 528.0 and pos.y >= 295.0 and pos.y <= 360.0:
		_use_horn()
	elif pos.x >= 535.0 and pos.x <= 640.0 and pos.y >= 255.0 and pos.y < 300.0:
		_use_nano()
	elif pos.x >= 535.0 and pos.x <= 640.0 and pos.y >= 300.0 and pos.y <= 360.0:
		# Keep PULO independent from the joystick finger.
		jump_requested = true

func _pointer_moved(pos: Vector2, pointer_id: int) -> void:
	if pointer_id != joystick_touch_id:
		return
	joystick_offset = (pos - joystick_origin).limit_length(JOYSTICK_RADIUS)
	_update_joystick_axes()
	queue_redraw()

func _pointer_released(pointer_id: int) -> void:
	if pointer_id == run_touch_id:
		run_touch_id = -1
		queue_redraw()
	if pointer_id == joystick_touch_id:
		_release_joystick()
		queue_redraw()

func _update_joystick_axes() -> void:
	var horizontal := joystick_offset.x
	var vertical := joystick_offset.y
	# Mantem um setor amplo para as diagonais baixo/esquerda e baixo/direita.
	if absf(horizontal) > JOYSTICK_DEADZONE and absf(horizontal) > absf(vertical) * 0.38:
		move_axis = 1.0 if horizontal > 0.0 else -1.0
	else:
		move_axis = 0.0
	# Somente um gesto essencialmente vertical aciona a escada.
	var on_vertical_axis := absf(vertical) > JOYSTICK_DEADZONE and absf(horizontal) <= absf(vertical) * 0.55
	climb_up_held = on_vertical_axis and vertical < 0.0
	climb_down_held = on_vertical_axis and vertical > 0.0
	# Para baixo parado = agachar; diagonal = andar agachado.
	# Quando uma escada esta ativa, _handle_ladder tem prioridade.
	crouch_held = vertical > JOYSTICK_DEADZONE

func _release_joystick() -> void:
	joystick_touch_id = -1
	joystick_origin = Vector2.ZERO
	joystick_offset = Vector2.ZERO
	move_axis = 0.0
	climb_up_held = false
	climb_down_held = false
	crouch_held = false
