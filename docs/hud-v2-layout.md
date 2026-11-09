# Chapolin Adventures — HUD v2 oficial

**Base:** Godot 4, canvas lógico horizontal **640 × 360**. Design inspirado em cinematic platformers de 16 bits, com leitura rápida no celular. Barra escura, metais envelhecidos e dourado discreto.

**Regra:** nunca alterar física, hitboxes de jogo, progressão, sprites oficiais ou comandos multitoque só para mudar a aparência. O atlas `res://assets/hud/icons_v2.svg` contém 8 ícones em células de 48 × 48: (0) emblema, (1) marreta, (2) corneta, (3) pulo, (4) nanicolina, (5) alavanca, (6) medalha, (7) pausa. Se a importação não funcionar, `main.gd` usa desenho de reserva.

## Tela 1 — Abertura

- Título e personagem oficial centralizam a identidade. Botões **CONTINUAR/JOGAR** e **NOVO JOGO**.
- **Continuar/Jogar:** `Rect2(60,245,211,54)`. **Novo jogo:** `Rect2(286,245,211,54)`.
- Nesta tela não se mostra HUD de combate nem inventário. Arquivo salvo preservado até a escolha de reiniciar.

## Tela 2 — Jogando

### Barra de informação — `x=0..640, y=0..48`

| Área | Coordenadas | Conteúdo |
| --- | --- | --- |
| Marca | x=0–112 | Emblema CH, Chapolin Adventures |
| Fase e objetivo | x=113–346 | **Cidade de Papelão** e instrução curta que muda conforme o progresso |
| Saúde | x=347–448 | 3 corações; vidas xN |
| Coletáveis | x=449–565 | Medalha e quantidade coletada da fase |
| Pausa | x=566–640 | Ícone de pausa na posição (600,24), círculo discreto |

**Ocultos do HUD principal:** lista de inimigos, segredos, checkpoint detalhado, inventário e textos explicativos longos.

### Controles do celular

| Comando | Centro visual | Raio visual | Área de toque, herdada da implementação aprovada |
| --- | --- | --- | --- |
| Joystick | flutuante onde o dedo encostar | 51 | x=0–320 e y=90–360, multitoque |
| Marreta | (376,329) | 27 | x=326–426; y=295–360 |
| Corneta | (479,329) | 27 | x=429–528; y=295–360 |
| **Pulo** — principal | (585,330) | 29 | x=535–640; y=300–360 |
| Nanicolina | (585,276) | 19 | x=535–640; y=255–299 |
| Usar alavanca, contextual | (580,229) | 20 | x=535–625; y=208–252; só quando perto |
| Pausa | (600,24) | 19 | x=572–634; y=4–52 |

A tecla E aciona alavancas no desktop. Escadas, cordas e agarrar bordas continuam utilizando o joystick.

### Estados e feedback

- **Disponível:** contorno dourado/temático e ícone nítido.
- **Não coletado ou sem cargas:** ícone apagado, ação desabilitada.
- **Recarregando:** arco progressivo no contorno.
- **Corneta/Nanicollina:** contador de cargas aparece somente depois da coleta.
- **Nanicolina ativa:** arco de duração.
- **Borda agarrada:** ajuda curta aparece temporariamente.
- **Salvo:** etiqueta discreta que desaparece.
- **Alavanca disponível:** botão USAR aparece; nunca deve ficar fixo.

## Tela 3 — Diálogos de história

- Overlay à frente do jogo e controles, com retrato, personagem e fala.
- Áreas de toque originais: **Pular cena** `Rect2(63,278,157,48)`; **Próximo/Continuar** `Rect2(403,278,169,48)`.
- A física é suspensa durante o diálogo, sem interferir no salvamento ou no fluxo da fase.

## Tela 4 — Pausa + inventário

- Ao tocar no ícone superior, jogo é pausado e o progresso é salvo.
- Centro: painel de inventário com **equipamentos** (marreta, corneta, nanicolina) à esquerda e **progresso** (medalhas, segredos, vidas, checkpoint) à direita.
- **Continuar:** `Rect2(140,251,166,43)` — retoma sem reiniciar. **Reiniciar fase:** `Rect2(332,251,166,43)` — reinicia fase e progresso conforme lógica existente.
- Ícones usam o mesmo atlas da HUD; sem duplicação de efeitos ou textos.

## Tela 5 — Fase concluída

- Overlay de resgate e contadores finais. Nenhum botão de combate deve tapar os elementos principais.
- **Reiniciar** preserva a hitbox existente `Rect2(509,298,120,51)`.
- A sequência de diálogos e o estado final continuam definidos pelas regras atuais.

## Tela 6 — Game over

- Overlay central com aviso de fim de vidas.
- Reinício pelo botão e pelo comando Pulo. A área física da reinicialização mantém `Rect2(509,298,120,51)`.

## Critérios de aceitação

1. Todos os elementos visuais ficam dentro de 640 × 360 e nenhum botão ultrapassa a própria área de toque.
2. A HUD permanece fixa durante rolagem do cenário e disponível ao personagem em movimento.
3. Joystick e botões suportam toques simultâneos no Android.
4. Ícones funcionam no Godot Android; se SVG falhar, a reserva desenhada mantém comandos legíveis.
5. Todos os tipos de interação são testados: coleta, recarga, pulo, alavanca, menu, diálogos, reinício e game over.
6. O cenário, as colisões, os dados salvos e os sprites oficiais permanecem intactos.

**Observação de validação:** verificações de estrutura e geometria no GitHub não substituem um teste real de renderização e multitoque no Godot Android.
