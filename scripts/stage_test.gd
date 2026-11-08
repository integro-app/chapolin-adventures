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

# Seis medalhas opcionais distribuidas pelas rotas mais importantes da fase.
static func medals() -> Array[Vector2]:
	return [
		Vector2(295.0, 220.0),
		Vector2(500.0, 183.0),
		Vector2(1105.0, 233.0),
		Vector2(1335.0, 183.0),
		Vector2(1880.0, 223.0),
		Vector2(2155.0, 186.0)
	]

# Marco seguro no chao, apos o primeiro desafio e a primeira corda.
static func checkpoint() -> Vector2:
	return Vector2(1435.0, 300.0)

# Porta de cenografia no final do mapa, para concluir a fase.
static func exit_door() -> Rect2:
	return Rect2(2312.0, 215.0, 49.0, 85.0)

# Figurantes mecanicos de papelao: (inicio do patrulhamento, fim, piso).
# Nunca cruzam os vaos nem iniciam no checkpoint.
static func enemy_patrols() -> Array[Vector3]:
	return [
		Vector3(910.0, 970.0, 300.0),
		Vector3(1815.0, 1890.0, 300.0),
		Vector3(2208.0, 2270.0, 300.0)
	]

# Rolos de cenografia se movimentam sobre o piso, de um lado para o outro.
static func moving_obstacles() -> Array[Vector3]:
	return [
		Vector3(1140.0, 1205.0, 300.0),
		Vector3(1980.0, 2045.0, 300.0)
	]

# Itens de combate: z=1 marreta, z=2 corneta, z=3 recarga de corneta.
# Coleta automatica. Posicoes acessiveis no inicio e apos o checkpoint.
static func combat_pickups() -> Array[Vector3]:
	return [
		Vector3(154.0, 270.0, 1.0),
		Vector3(365.0, 222.0, 2.0),
		Vector3(1730.0, 270.0, 3.0)
	]

# Nanicolina: pequena capsula coletada antes do tunel de papelão.
static func nano_pickups() -> Array[Vector2]:
	return [
		Vector2(1250.0, 270.0)
	]

# Telhado baixo sobre o piso: so o Chapolin miniatura atravessa por baixo.
# Fica antes do checkpoint (x=1435), preservando respawn em area aberta.
static func nano_tunnels() -> Array[Rect2]:
	return [
		Rect2(1342.0, 244.0, 68.0, 20.0)
	]

# Apenas estas bordas podem ser agarradas: (x da borda, y do topo, lado).
# lado 1 = a plataforma fica a direita do Chapolin; -1 = a esquerda.
# Escolhidas longe das cordas, escadas, caixas e tunel da Nanicolina.
static func ledge_grab_points() -> Array[Vector3]:
	return [
		Vector3(447.0, 212.0, 1.0),
		Vector3(1225.0, 214.0, 1.0)
	]

# Plataformas moveis horizontais independentes das plataformas fixas.
# Cada uma percorre um trilho entre min_x e max_x; "y" e o topo.
# A primeira conecta os patamares centrais; a segunda evita um rolo.
static func moving_platforms() -> Array[Dictionary]:
	return [
		{"min_x": 1105.0, "max_x": 1215.0, "y": 194.0, "width": 74.0, "speed": 45.0},
		{"min_x": 1915.0, "max_x": 2050.0, "y": 213.0, "width": 70.0, "speed": 52.0}
	]

# Alavancas de estúdio: z=1 destrava a grade; z=2 liga a plataforma 2.
# Primeira junto ao checkpoint (antes da grade), segunda depois do vao.
static func levers() -> Array[Vector3]:
	return [
		Vector3(1480.0, 300.0, 1.0),
		Vector3(1910.0, 300.0, 2.0)
	]

# Grade acionada pela primeira alavanca, independente da placa/caixa.
static func lever_gate() -> Rect2:
	return Rect2(1538.0, 141.0, 16.0, 159.0)

# Paineis falsos opcionais: so a Marreta Bionica pode despedaça-los.
# Ficam sobre plataformas com acesso pela escada, fora da rota obrigatoria.
static func fragile_walls() -> Array[Rect2]:
	return [
		Rect2(558.0, 168.0, 22.0, 44.0),
		Rect2(2175.0, 174.0, 22.0, 44.0)
	]

# Medalhas secretas reveladas apos destruir os paineis.
# A primeira recupera 1 coracao, a segunda concede 1 vida (ate 5).
static func secret_rewards() -> Array[Vector2]:
	return [
		Vector2(585.0, 185.0),
		Vector2(2205.0, 185.0)
	]

# Roteiro curto do prologo, sem alterar o mapa e as regras do tutorial.
# Dados externos a main.gd para reaproveitar o sistema em futuros episodios.
static func story_dialogue(scene_id: String) -> Array[Dictionary]:
	match scene_id:
		"intro":
			return [
				{"speaker": "MORADORA", "line1": "Socorro! O estudio virou uma cidade", "line2": "cheia de armadilhas de papelao!"},
				{"speaker": "MORADORA", "line1": "E agora, quem podera", "line2": "nos defender?"},
				{"speaker": "CHAPOLIN", "line1": "Eu! O Chapolin Colorado!", "line2": "Vou encontrar a saida!"}
			]
		"checkpoint":
			return [
				{"speaker": "MORADORA", "line1": "Chapolin! Estou perto da saida!", "line2": "A proxima grade tem uma alavanca."},
				{"speaker": "CHAPOLIN", "line1": "Entendido! E que ninguem", "line2": "se afobe com estes cenarios!"}
			]
		"rescue":
			return [
				{"speaker": "MORADORA", "line1": "Voce conseguiu! Os mecanismos", "line2": "pararam. Estou a salvo!"},
				{"speaker": "CHAPOLIN", "line1": "Nao contavam com minha astucia!", "line2": "Agora, vamos embora!"}
			]
	return []

# Atriz/figurante da cidade: perto da porta final, fora da patrulha.
static func rescue_npc() -> Vector2:
	return Vector2(2292.0, 300.0)
