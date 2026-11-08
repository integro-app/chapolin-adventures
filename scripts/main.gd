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
var crates: Array[Rect2] = []
var pressure_plates: Array[Rect2] = []
var puzzle_gates: Array[Rect2] = []
var puzzle_gate_open := false
var medals: Array[Vector2] = []
var medal_collected: Array[bool] = []
var medal_count := 0
var respawn_point := Stage.RESPAWN
var checkpoint_active := false
var stage_complete := false
var finish_medals := 0
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
var low_beams: Array[Rect2] = []
var ladders: Array[Rect2] = []
var ropes: Array[Vector3] = []
var idle_texture: Texture2D
var walk_texture: Texture2D
var run_texture: Texture2D
var jump_texture: Texture2D

func _ready() -> void:
	# Pixel-art filtering prevents neighboring atlas pixels bleeding into frames.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground_segments = Stage.ground()
	raised_platforms = Stage.platforms()
	ledge_grab_points = Stage.ledge_grab_points()
	crates = Stage.crates()
	pressure_plates = Stage.pressure_plates()
	puzzle_gates = Stage.puzzle_gates()
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

	# Mesmos sprites aprovados para idle, caminhada e salto.
	if ResourceLoader.exists("res://assets/chapolin_idle.png"):
		idle_texture = load("res://assets/chapolin_idle.png")
	if ResourceLoader.exists("res://assets/chapolin/walk.png"):
		walk_texture = load("res://assets/chapolin/walk.png")
	if ResourceLoader.exists("res://assets/chapolin/run.png"):
		run_texture = load("res://assets/chapolin/run.png")
	if ResourceLoader.exists("res://assets/chapolin/jump.png"):
		jump_texture = load("res://assets/chapolin/jump.png")
	_load_game()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if save_dirty:
		save_delay -= delta
		if save_delay <= 0.0:
			_save_game()
	save_notice_time = maxf(0.0, save_notice_time - delta)
	if pause_menu_open:
		queue_redraw()
		return
	if stage_complete or game_over:
		if Input.is_action_just_pressed("ui_accept") or jump_requested:
			_restart_stage()
		jump_requested = false
		queue_redraw()
		return
	var previous_foot_y: float = hero_pos.y
	_update_nano_timer(delta)
	hammer_cooldown = maxf(0.0, hammer_cooldown - delta)
	hammer_swing_time = maxf(0.0, hammer_swing_time - delta)
	horn_cooldown = maxf(0.0, horn_cooldown - delta)
	horn_effect_time = maxf(0.0, horn_effect_time - delta)
	hurt_grace = maxf(0.0, hurt_grace - delta)
	hazard_clock += delta
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
		return
	if _handle_rope(delta):
		if not _check_threat_collisions(previous_foot_y):
			_update_level_progress()
		return
	if _handle_ladder(delta):
		if not _check_threat_collisions(previous_foot_y):
			_update_level_progress()
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
	running = direction != 0 and grounded and not is_crouching and run_hold_time >= RUN_DELAY and run_texture != null
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
		if not _check_threat_collisions(previous_foot_y):
			_update_level_progress()
		return

	if grounded:
		if not was_grounded:
			landing_timer = 0.16
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

	# A câmera acompanha suavemente, respeitando as bordas do mundo.
	var camera_target := clampf(hero_pos.x - 215.0, 0.0, Stage.WORLD_WIDTH - SCREEN_WIDTH)
	camera_x = lerpf(camera_x, camera_target, minf(1.0, delta * 6.5))
	queue_redraw()


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

	# A grade e solida ate a caixa ativar a placa de pressao.
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

func _use_hammer() -> void:
	if stage_complete or game_over or not hammer_unlocked or hammer_cooldown > 0.0:
		return
	hammer_cooldown = HAMMER_COOLDOWN
	hammer_swing_time = HAMMER_SWING_DURATION
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
	queue_redraw()

func _use_horn() -> void:
	if stage_complete or game_over or not horn_unlocked or horn_charges <= 0 or horn_cooldown > 0.0:
		return
	horn_charges -= 1
	_mark_save_dirty()
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
		"health": health,
		"lives": lives,
		"hammer_unlocked": hammer_unlocked,
		"horn_unlocked": horn_unlocked,
		"horn_charges": horn_charges,
		"nano_unlocked": nano_unlocked,
		"nano_charges": nano_charges,
		"stage_complete": stage_complete,
		"game_over": game_over
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

	medal_count = medal_collected.count(true)
	health = clampi(int(data.get("health", MAX_HEALTH)), 1, MAX_HEALTH)
	lives = clampi(int(data.get("lives", MAX_LIVES)), 0, MAX_LIVES)
	hammer_unlocked = bool(data.get("hammer_unlocked", false))
	horn_unlocked = bool(data.get("horn_unlocked", false))
	horn_charges = clampi(int(data.get("horn_charges", 0)), 0, HORN_MAX_CHARGES)
	nano_unlocked = bool(data.get("nano_unlocked", false))
	nano_charges = clampi(int(data.get("nano_charges", 0)), 0, NANO_MAX_CHARGES)
	stage_complete = bool(data.get("stage_complete", false))
	game_over = bool(data.get("game_over", false)) or lives == 0
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

func _update_level_progress() -> void:
	_collect_combat_pickups()
	_collect_nano_pickups()
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

	var mark: Vector2 = Stage.checkpoint()
	if not checkpoint_active and grounded:
		if absf(hero_pos.x - mark.x) <= 31.0 and absf(hero_pos.y - mark.y) <= 7.0:
			checkpoint_active = true
			respawn_point = mark
			_mark_save_dirty()

	var door: Rect2 = Stage.exit_door()
	if not stage_complete and puzzle_gate_open and grounded:
		if hero_pos.x >= door.position.x - 4.0 and hero_pos.x <= door.end.x + 4.0:
			if absf(hero_pos.y - door.end.y) < 8.0:
				finish_medals = medal_count
				stage_complete = true
				_mark_save_dirty()
				move_axis = 0.0
				running = false
				jump_requested = false

func _restart_stage() -> void:
	# Recomeca a fase inteira; cair ou levar dano nao apaga o progresso.
	pause_menu_open = false
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
	crates = Stage.crates()
	checkpoint_active = false
	respawn_point = Stage.RESPAWN
	stage_complete = false
	finish_medals = 0
	medal_count = 0
	hazard_clock = 0.0
	_reset_enemies()
	for i in range(medal_collected.size()):
		medal_collected[i] = false
	_release_joystick()
	_respawn()
	camera_x = 0.0
	current_animation = "idle"
	animation_time = 0.0
	_save_game()
	queue_redraw()

func _respawn() -> void:
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
	for ladder in ladders:
		_draw_ladder(ladder)
	for surface in ground_segments:
		_draw_stone(surface, true)
	for surface in raised_platforms:
		_draw_stone(surface, false)
	_draw_ledge_grab_markers()
	for plate in pressure_plates:
		_draw_pressure_plate(plate)
	for gate in puzzle_gates:
		_draw_puzzle_gate(gate)
	for block in crates:
		_draw_crate(block)
	for beam in low_beams:
		_draw_low_beam(beam)
	for tunnel in nano_tunnels:
		_draw_nano_tunnel(tunnel)
	for rope in ropes:
		_draw_rope(rope)
	_draw_checkpoint()
	_draw_exit_door()
	for i in range(medals.size()):
		if not medal_collected[i]:
			_draw_medal(medals[i])
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
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_controls()
	if pause_menu_open:
		_draw_pause_inventory()
	if stage_complete:
		_draw_finish_screen()
	elif game_over:
		_draw_game_over()

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
	# Figurante de papelão com pernas mecanicas e olhos quadrados.
	var body := Rect2(pos.x - 13.0, pos.y - 27.0, 26.0, 25.0)
	draw_rect(body, Color("#4a3840"))
	draw_rect(Rect2(pos.x - 10.0, pos.y - 24.0, 20.0, 19.0), Color("#c48f67"))
	draw_rect(Rect2(pos.x - 8.0, pos.y - 21.0, 16.0, 7.0), Color("#78505a"))
	var eye_shift: float = direction * 2.0
	draw_rect(Rect2(pos.x - 6.0 + eye_shift, pos.y - 20.0, 4.0, 4.0), Color("#f6dea8"))
	draw_rect(Rect2(pos.x + 2.0 + eye_shift, pos.y - 20.0, 4.0, 4.0), Color("#f6dea8"))
	draw_line(Vector2(pos.x - 8.0, pos.y - 2.0), Vector2(pos.x - 8.0, pos.y + 1.0), Color("#45373a"), 4.0)
	draw_line(Vector2(pos.x + 8.0, pos.y - 2.0), Vector2(pos.x + 8.0, pos.y + 1.0), Color("#45373a"), 4.0)
	draw_line(Vector2(pos.x, pos.y - 27.0), Vector2(pos.x, pos.y - 33.0), Color("#7d655a"), 2.0)
	draw_circle(Vector2(pos.x, pos.y - 34.0), 3.0, Color("#d5ac71"))
	if stunned:
		draw_circle(Vector2(pos.x, pos.y - 35.0), 18.0, Color(0.37, 0.78, 0.90, 0.12))
		draw_arc(Vector2(pos.x, pos.y - 35.0), 18.0, 0.0, TAU, 24, Color("#86d7e9"), 2.0)
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
	draw_string(ThemeDB.fallback_font, Vector2(199.0, 235.0), "PRIMEIRO EPISODIO COMPLETO", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#e9c8a0"))
	# A tela cobre o HUD, entao o reinicio precisa ficar visivel.
	# A area coincide com o botao PULO, que continua acionando o reinicio.
	draw_rect(Rect2(509.0, 298.0, 120.0, 51.0), Color("#b78351"))
	draw_rect(Rect2(514.0, 302.0, 110.0, 43.0), Color("#634b40"))
	draw_string(ThemeDB.fallback_font, Vector2(519.0, 329.0), "REINICIAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func _draw_crate(block: Rect2) -> void:
	# Caixa cenografica com travessas, pregos e etiqueta de inventario.
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
	# Escada de madeira real de cenografia, com degraus e ferragens.
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
	# Inventario consultavel durante a pausa, sem cobrir o direcional em jogo.
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color(0.07, 0.08, 0.11, 0.83))
	draw_rect(Rect2(82.0, 45.0, 476.0, 264.0), Color("#332d39"))
	draw_rect(Rect2(88.0, 51.0, 464.0, 252.0), Color("#51404a"))
	draw_string(ThemeDB.fallback_font, Vector2(240.0, 84.0), "JOGO PAUSADO", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#f6d2a0"))
	draw_string(ThemeDB.fallback_font, Vector2(122.0, 119.0), "INVENTARIO", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f6d2a0"))
	draw_string(ThemeDB.fallback_font, Vector2(122.0, 150.0), "MARRETA: " + ("COLETADA" if hammer_unlocked else "NAO COLETADA"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(122.0, 179.0), "CORNETA: %d CARGAS" % horn_charges, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(122.0, 208.0), "NANICOLINA: %d USOS" % nano_charges, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(340.0, 148.0), "MEDALHAS: %d/%d" % [medal_count, medals.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ead59d"))
	draw_string(ThemeDB.fallback_font, Vector2(340.0, 179.0), "VIDAS: %d" % lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f3e1ce"))
	draw_string(ThemeDB.fallback_font, Vector2(340.0, 208.0), "CHECKPOINT: " + ("SIM" if checkpoint_active else "NAO"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c7dfcb"))
	draw_rect(Rect2(140.0, 251.0, 166.0, 43.0), Color("#466856"))
	draw_rect(Rect2(332.0, 251.0, 166.0, 43.0), Color("#84604b"))
	draw_string(ThemeDB.fallback_font, Vector2(177.0, 279.0), "CONTINUAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(357.0, 279.0), "REINICIAR FASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)

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
	# Tres coracoes indicam resistencia; vidas sao tentativas inteiras.
	for i in range(MAX_HEALTH):
		var x: float = 15.0 + float(i) * 25.0
		var y: float = 64.0
		var heart_color := Color("#d44f55") if i < health else Color("#483f47")
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + 2.0, y + 5.0), Vector2(x + 6.0, y + 1.0),
			Vector2(x + 11.0, y + 2.0), Vector2(x + 13.0, y + 5.0),
			Vector2(x + 16.0, y + 2.0), Vector2(x + 21.0, y + 1.0),
			Vector2(x + 24.0, y + 5.0), Vector2(x + 24.0, y + 11.0),
			Vector2(x + 13.0, y + 21.0), Vector2(x + 2.0, y + 11.0)
		]), heart_color)
	draw_string(ThemeDB.fallback_font, Vector2(98.0, 80.0), "VIDAS: %d" % lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f2ddbc"))

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

func _draw_controls() -> void:
	# O joystick so aparece enquanto um dedo toca a metade esquerda da tela.
	# Diagonal para baixo + lateral = caminhar agachado, sem botao dedicado.
	if joystick_touch_id != -1:
		draw_circle(joystick_origin, JOYSTICK_RADIUS, Color(0.06, 0.12, 0.17, 0.38))
		draw_arc(joystick_origin, JOYSTICK_RADIUS, 0.0, TAU, 36, Color(0.92, 0.79, 0.62, 0.48), 2.0)
		draw_circle(joystick_origin, 8.0, Color(0.81, 0.71, 0.59, 0.44))
		var knob := joystick_origin + joystick_offset
		draw_circle(knob, 23.0, Color(0.12, 0.23, 0.30, 0.86))
		draw_circle(knob, 18.0, Color(0.42, 0.53, 0.53, 0.88))
		draw_circle(knob, 8.0, Color("#f1d9b5"))

	# Dois ataques independentes e o PULO. Joystick permanece invisivel.
	var hammer_color := Color("#665244") if hammer_unlocked else Color("#283540")
	var horn_color := Color("#426274") if horn_unlocked and horn_charges > 0 else Color("#283540")
	if hammer_swing_time > 0.0:
		hammer_color = Color("#937252")
	if horn_effect_time > 0.0:
		horn_color = Color("#438aa5")
	draw_rect(Rect2(326.0, 310.0, 98.0, 38.0), hammer_color)
	draw_rect(Rect2(429.0, 310.0, 98.0, 38.0), horn_color)
	draw_string(ThemeDB.fallback_font, Vector2(338.0, 334.0), "MARRETA", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(438.0, 334.0), "CORNETA %d" % horn_charges, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	draw_rect(Rect2(535.0, 310.0, 90.0, 38.0), Color("#263c53"))
	draw_string(ThemeDB.fallback_font, Vector2(545.0, 335.0), "PULO", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	var nano_color := Color("#6c9973") if _nano_active() else (Color("#496551") if nano_unlocked and nano_charges > 0 else Color("#283540"))
	draw_rect(Rect2(535.0, 261.0, 90.0, 37.0), nano_color)
	var nano_label := "NANO %ds" % int(ceil(nano_remaining)) if _nano_active() else "NANO %d" % nano_charges
	draw_string(ThemeDB.fallback_font, Vector2(543.0, 284.0), nano_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(15.0, 26.0), "CIDADE DE PAPELAO  |  CENARIO DE TESTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f0cfaa"))
	var puzzle_text := "GRADE ABERTA!" if puzzle_gate_open else "DESAFIO: EMPURRE A CAIXA ATE A PLACA"
	draw_string(ThemeDB.fallback_font, Vector2(15.0, 47.0), puzzle_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#e9d1ac"))
	draw_string(ThemeDB.fallback_font, Vector2(504.0, 26.0), "CH %d/%d" % [medal_count, medals.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f6d47b"))
	if checkpoint_active:
		draw_string(ThemeDB.fallback_font, Vector2(504.0, 47.0), "CHECKPOINT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#9ddea8"))
	draw_string(ThemeDB.fallback_font, Vector2(504.0, 65.0), "ROBOS %d/%d" % [enemy_active.size() - enemy_active.count(false), enemy_active.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#e0bf9c"))
	_draw_health_hud()
	if ledge_hanging:
		draw_string(ThemeDB.fallback_font, Vector2(181.0, 79.0), "BORDA: CIMA SOBE | BAIXO SOLTA", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f5d7a0"))
	if not stage_complete and not game_over:
		draw_rect(Rect2(551.0, 89.0, 76.0, 29.0), Color("#304052"))
		draw_string(ThemeDB.fallback_font, Vector2(559.0, 108.0), "PAUSA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f0dbc4"))
	if save_notice_time > 0.0 and not pause_menu_open:
		draw_string(ThemeDB.fallback_font, Vector2(552.0, 141.0), "SALVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#a8d6ae"))

func _input(event: InputEvent) -> void:
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
	if (stage_complete or game_over) and Rect2(509.0, 298.0, 120.0, 51.0).has_point(pos):
		jump_requested = true
		return
	if pause_menu_open:
		if Rect2(140.0, 251.0, 166.0, 43.0).has_point(pos):
			pause_menu_open = false
		elif Rect2(332.0, 251.0, 166.0, 43.0).has_point(pos):
			_restart_stage()
		queue_redraw()
		return
	if not stage_complete and not game_over and Rect2(551.0, 89.0, 76.0, 29.0).has_point(pos):
		pause_menu_open = true
		_release_joystick()
		jump_requested = false
		_save_game()
		queue_redraw()
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
