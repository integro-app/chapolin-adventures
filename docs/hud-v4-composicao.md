# HUD v4 oficial — Chapolin Adventures
A barra anterior (`assets/hud/v3/hud_bar.webp`) trazia coracoes vazios, moldura da medalha e outros elementos graficos embutidos. O programa desenhava novos icones nas mesmas posicoes, causando a sobreposicao observada no Godot Android.

## Arte limpa
- `assets/hud/v4/hud_bar_clean.webp` — 1280x130, moldura e logotipo, sem contadores nem coracoes gravados.
- `assets/hud/v4/hud_status_icons.webp` — 768x96, atlas de 8 icones em celulas 96x96: (0) coracao cheio, (1) vazio, (2) metade, (3) retrato, (4) moeda, (5) caixa, (6) pausa, (7) seta do objetivo.
- `assets/hud/v3/hud_controls.webp` e `assets/hud/v3/hud_icons.webp` permanecem para os comandos de toque e ferramentas, sem alterar suas areas de interacao.

A composicao superior e desenhada uma vez por `_draw_controls_v3`, com as variaveis reais de saude, vidas, medalhas, caixas e objetivo. A funcao `_hud_v3_ready` exige agora os arquivos limpos. A barra antiga foi excluida da pasta do projeto e da verificacao de sincronizacao.

## Atualizacao Android
Executar o sincronizador oficial, de preferencia com `CHAPOLIN_REIMPORT=1`; ele busca a `main`, limpa arquivos obsoletos via `rsync --delete`, verifica os dois arquivos v4, confere a ausencia do antigo e mostra o commit instalado no menu de pausa.

**Validacao necessaria:** abrir o projeto `Documents/ChapolinAdventures/project.godot`, conferir o topo visual e testar joystick, correr, pulo, interagir, habilidades, pausa e carregamento do save. A verificacao de codigo nao substitui a execucao no editor Godot Android.
