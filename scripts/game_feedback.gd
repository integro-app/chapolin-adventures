extends RefCounted
# Feedback cinematografico de baixo custo para Android.
# Particulas em coordenadas do mundo; nenhuma delas altera fisica ou colisao.
const PARTICLE_LIFETIME := 0.50
const LABEL_LIFETIME := 1.30
const PARTICLE_LIMIT := 80
const LABEL_LIMIT := 4

var sparks: Array[Dictionary] = []
var labels: Array[Dictionary] = []
var clock := 0.0

func reset() -> void:
	sparks.clear()
	labels.clear()
	clock = 0.0

func burst(origin: Vector2, kind: String, text: String = "") -> void:
	var color := Color("#e6cda2")
	match kind:
		"hurt":
			color = Color("#f06d7e")
		"horn":
			color = Color("#87d7ef")
		"nano":
			color = Color("#9cdaa9")
		"medal", "pickup", "checkpoint", "secret":
			color = Color("#ffe097")
		"enemy":
			color = Color("#e8b5a0")
		"wood":
			color = Color("#cf9871")
		"jump", "land", "ledge":
			color = Color("#d6bea5")

	var amount: int = 12 if kind == "checkpoint" or kind == "wood" else 7
	for i in range(amount):
		var angle: float = float(i) * TAU / float(amount) + clock * 0.4
		var strength: float = 53.0 + float(i % 4) * 19.0
		var velocity := Vector2(cos(angle) * strength, sin(angle) * strength - 28.0)
		sparks.append({
			"position": origin,
			"velocity": velocity,
			"life": PARTICLE_LIFETIME,
			"color": color
		})
	while sparks.size() > PARTICLE_LIMIT:
		sparks.pop_front()

	if not text.is_empty():
		labels.append({
			"position": origin + Vector2(0.0, -39.0),
			"life": LABEL_LIFETIME,
			"text": text,
			"color": color
		})
		while labels.size() > LABEL_LIMIT:
			labels.pop_front()

func tick(delta: float) -> void:
	clock += delta
	for i in range(sparks.size() - 1, -1, -1):
		var spark: Dictionary = sparks[i]
		var life: float = float(spark["life"]) - delta
		if life <= 0.0:
			sparks.remove_at(i)
			continue
		var velocity: Vector2 = spark["velocity"]
		spark["position"] = Vector2(spark["position"]) + velocity * delta
		spark["velocity"] = velocity * maxf(0.0, 1.0 - 2.4 * delta) + Vector2(0.0, 140.0 * delta)
		spark["life"] = life
		sparks[i] = spark

	for i in range(labels.size() - 1, -1, -1):
		var msg: Dictionary = labels[i]
		var life: float = float(msg["life"]) - delta
		if life <= 0.0:
			labels.remove_at(i)
			continue
		msg["position"] = Vector2(msg["position"]) + Vector2(0.0, -13.0 * delta)
		msg["life"] = life
		labels[i] = msg

func draw_on(canvas: CanvasItem) -> void:
	# So invocar durante Node2D._draw(), depois do personagem.
	for spark in sparks:
		var pos: Vector2 = spark["position"]
		var tint: Color = spark["color"]
		var alpha: float = clampf(float(spark["life"]) / PARTICLE_LIFETIME, 0.0, 1.0)
		canvas.draw_rect(Rect2(pos.x - 2.0, pos.y - 2.0, 4.0, 4.0), Color(tint.r, tint.g, tint.b, alpha))

	for msg in labels:
		var pos: Vector2 = msg["position"]
		var caption: String = msg["text"]
		var tint: Color = msg["color"]
		var alpha: float = clampf(float(msg["life"]) / LABEL_LIFETIME, 0.0, 1.0)
		var width: float = maxf(58.0, float(caption.length()) * 7.2 + 16.0)
		canvas.draw_rect(Rect2(pos.x - width * 0.5, pos.y - 18.0, width, 23.0), Color(0.07, 0.08, 0.15, alpha * 0.83))
		canvas.draw_rect(Rect2(pos.x - width * 0.5, pos.y - 18.0, 3.0, 23.0), Color(tint.r, tint.g, tint.b, alpha))
		canvas.draw_string(ThemeDB.fallback_font, Vector2(pos.x - width * 0.5 + 8.0, pos.y - 3.0), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.96, 0.87, alpha))
