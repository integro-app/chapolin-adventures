extends RefCounted
# Fase de testes: áreas de colisão em coordenadas do mundo.
# Mantém cenário e jogabilidade separados para acrescentar fases depois.
const WORLD_WIDTH := 2400.0
const FLOOR_Y := 300.0
const RESPAWN := Vector2(120.0, 300.0)

static func ground() -> Array[Rect2]:
	return [
		Rect2(0.0, 300.0, 785.0, 60.0),
		Rect2(855.0, 300.0, 705.0, 60.0),
		Rect2(1640.0, 300.0, 760.0, 60.0)
	]

static func platforms() -> Array[Rect2]:
	return [
		Rect2(245.0, 252.0, 160.0, 18.0),
		Rect2(447.0, 212.0, 150.0, 18.0),
		Rect2(695.0, 252.0, 195.0, 18.0),
		Rect2(1000.0, 254.0, 165.0, 18.0),
		Rect2(1225.0, 214.0, 160.0, 18.0),
		Rect2(1515.0, 252.0, 200.0, 18.0),
		Rect2(1830.0, 255.0, 170.0, 18.0),
		Rect2(2070.0, 218.0, 150.0, 18.0)
	]

static func crates() -> Array[Rect2]:
	return [
		Rect2(595.0, 264.0, 36.0, 36.0),
		Rect2(1095.0, 266.0, 34.0, 34.0),
		Rect2(1760.0, 266.0, 34.0, 34.0)
	]


# Barras leves de cenografia: o heroi passa por baixo ao agachar.
# Ficam acima do piso e abaixo da cabeca do personagem em pe.
static func low_beams() -> Array[Rect2]:
	return [
		Rect2(177.0, 187.0, 60.0, 23.0),
		Rect2(912.0, 187.0, 72.0, 23.0),
		Rect2(1683.0, 187.0, 62.0, 23.0)
	]

# Escadas de madeira presas aos paineis do estudio: de um piso ate a plataforma.
# Rect2(x, topo_da_plataforma, largura, distancia_ate_o_chao)
static func ladders() -> Array[Rect2]:
	return [
		Rect2(330.0, 252.0, 22.0, 48.0),
		Rect2(519.0, 212.0, 22.0, 88.0),
		Rect2(1293.0, 214.0, 22.0, 86.0),
		Rect2(2110.0, 218.0, 22.0, 82.0)
	]

# Cordas suspensas dos refletores: x/y = ancora, z = comprimento da corda.
# Posicionadas nas duas passagens para permitir balancar sobre os vaos.
static func ropes() -> Array[Vector3]:
	return [
		Vector3(818.0, 102.0, 120.0),
		Vector3(1595.0, 100.0, 122.0)
	]

# Primeiro desafio: empurre a primeira caixa sobre a placa para abrir a grade.
# A placa fica sobre o piso, antes da travessia do primeiro vao.
static func pressure_plates() -> Array[Rect2]:
	return [
		Rect2(680.0, 296.0, 44.0, 4.0)
	]

static func puzzle_gates() -> Array[Rect2]:
	return [
		Rect2(744.0, 169.0, 18.0, 131.0)
	]
