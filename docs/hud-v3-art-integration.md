# HUD v3 — integração das artes aprovadas (Godot / Android)

## Resultado

A HUD v3 substitui visualmente a HUD protótipo **somente quando os três WebP foram importados com sucesso**. O código mantém a HUD v2 como fallback sem trocar colisões nem sprites do jogo. O canvas base é **640 × 360**, em orientação paisagem.

Artes otimizadas da geração aprovada, recortadas em imagens independentes com transparência:

| Recurso | Arquivo | Tamanho | Layout |
|---|---|---|---|
| Barra superior | `assets/hud/v3/hud_bar.webp` | 1280 × 154 | Imagem única; desenhada em `Rect2(0,0,640,64)` |
| Ícones | `assets/hud/v3/hud_icons.webp` | 448 × 448 | Atlas 4 colunas, células de 112 × 112 |
| Controles | `assets/hud/v3/hud_controls.webp` | 408 × 272 | Atlas 3 colunas, células de 136 × 136 |

Os arquivos de arte permanecem separados do código para que possam ser substituídos ou refinados sem reprogramar a fase.

## Índices dos atlases

**Ícones v3** (ordem por linha): 0 coração cheio; 1 meio coração; 2 coração vazio; 3 retrato; 4 medalha CH; 5 caixa; 6 mão/usar; 7 pulo; 8 correr; 9 marreta; 10 corneta; 11 Nanicolina; 12 alavanca; 13 pausa.

**Controles v3:** 0 anel do joystick; 1 botão central do joystick; 2 pulo; 3 mão/usar; 4 correr; 5 botão circular vazio.

## Mapa final dos controles

| Ação | Centro visual | Região de toque `Rect2(x,y,w,h)` | Comportamento |
|---|---|---|---|
| Movimento | Joystick flutuante; guia em (80,296) | Metade esquerda, x=0–320 e y=90–360 | Continua com multitouch, caminhada, agachamento e escadas |
| Marreta | (354,327) | (329,299,51,61) | Ativa quando coletada e fora de recarga |
| Corneta | (414,327) | (386,299,53,61) | Gasta carga, paralisa inimigos |
| Nanicolina | (466,260) | (441,233,50,53) | Encolhe, com contador/duração |
| **Usar** | (508,323) | (476,288,62,71) | Ativa alavanca próxima; cinza quando indisponível |
| **Pulo** | (585,323) | (547,283,87,77) | Pulo independente do joystick |
| **Correr** | (588,244) | (554,206,82,75) | Pressione e mantenha com segundo dedo: corrida imediata; corrida automática após `RUN_DELAY` permanece |
| Pausa | (623,13) | (600,0,40,29) | Abre menu de pausa e salva progresso |

Todos os centros e diâmetros desenhados cabem inteiramente nas respectivas hitboxes. Não há sobreposição entre as áreas de comando. A captura de tela real do Android determina refinamentos visuais seguintes.

## Dados reais exibidos

- **Corações:** saúde atual, entre zero e `MAX_HEALTH`.
- **Retrato e vidas:** usa o contador `lives` real.
- **Medalhas:** contador `medal_count` persistido, não um exemplo fixo.
- **Caixas:** quantidade das três caixas existentes movidas mais de 4 unidades de sua posição inicial; obtida das posições `crates` já salvas.
- **Objetivo:** acompanha a abertura de grades, checkpoint, alavancas e resgate.
- **Ferramentas:** aparecem habilitadas somente após coleta e disponibilidade; recarga/duração visíveis.

## Segurança do progresso e fallback

- `user://chapolin_save_v1.json` continua no mesmo formato e versão.
- Não foram alterados os sprites oficiais, as coordenadas de mundo, as colisões, a ordem dos inimigos ou a resolução física.
- `main.gd` verifica `ResourceLoader.exists` e apresenta a HUD anterior caso falte qualquer arquivo WebP.
- A corrida por toque não remove corrida automática nem muda a velocidade de corrida já existente.
- Em reinício da fase, respawn e entrada pela tela inicial, o estado de correr pressionado é liberado.

## Homologação em Godot Android

1. Fechar o editor Godot e atualizar com `bash ~/chapolin-adventures/tools/android-sync.sh`.
2. Abrir a fase, conferir que a barra superior exibe os gráficos completos (e não a HUD antiga).
3. Conferir joystick com um dedo e **PULO + CORRER** com segundo dedo.
4. Coletar Marreta, Corneta e Nanicolina e usar os botões correspondentes.
5. Tocar em **USAR** perto de uma alavanca. Fora de alcance, não deve executar nada.
6. Confirmar contadores de corações, vidas, medalhas e movimentação das 3 caixas.
7. Testar o botão de pausa, continuar, reiniciar, som e as cenas de história.
8. Confirmar continuidade de salvamentos existentes.

**Status:** checagem estática do repositório e de dimensões concluída; execução visual/interativa no Godot Android ainda precisa ser homologada no dispositivo.
