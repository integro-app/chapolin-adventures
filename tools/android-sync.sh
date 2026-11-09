#!/usr/bin/env bash
# Instalador reproduzivel para o Godot Android: sempre usa a main oficial.
# Requer Termux: pkg install git rsync tar; termux-setup-storage.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${CHAPOLIN_GODOT_DIR:-$HOME/storage/shared/Documents/ChapolinAdventures}"
OFFICIAL_REMOTE="https://github.com/integro-app/chapolin-adventures.git"

if [[ ! -d "$HOME/storage/shared" ]]; then
  echo "Acesso ao armazenamento nao configurado. Execute termux-setup-storage" >&2
  exit 1
fi
if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "Repositorio local nao encontrado: $REPO_DIR" >&2
  exit 1
fi
for binary in git rsync tar mktemp cmp; do
  if ! command -v "$binary" >/dev/null 2>&1; then
    echo "Falta o comando $binary. Execute: pkg install git rsync tar" >&2
    exit 1
  fi
done

echo "Chapolin Adventures: obtendo a branch MAIN oficial..."
# Nao depende da branch que ficou aberta no Termux e nao altera
# edicoes locais ou commits do repositorio de trabalho do usuario.
git -C "$REPO_DIR" fetch --no-tags "$OFFICIAL_REMOTE" main
REVISION="$(git -C "$REPO_DIR" rev-parse --verify FETCH_HEAD)"
SHORT_REV="${REVISION:0:12}"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
git -C "$REPO_DIR" archive --format=tar "$REVISION" | tar -xf - -C "$TEMP_DIR"
printf 'Chapolin Adventures | GitHub main\nCommit: %s\nProjeto Godot: %s/project.godot\n' "$REVISION" "$DEST_DIR" > "$TEMP_DIR/CHAPOLIN_VERSAO.txt"

mkdir -p "$DEST_DIR"
# --checksum evita ignorar codigo novo por timestamps identicos.
# Nunca leva .git nem apaga o user:// do Android.
# Preserva .godot, exceto se for solicitada reimportacao.
rsync -rc --delete --exclude='/.godot/' "$TEMP_DIR/" "$DEST_DIR/"
if [[ "${CHAPOLIN_REIMPORT:-0}" == "1" ]]; then
  echo "Limpando somente o cache gerado pelo Godot para reimportacao..."
  rm -rf -- "$DEST_DIR/.godot"
fi

# Checa o conteudo que foi de fato copiado para o Android.
if ! cmp -s "$TEMP_DIR/scripts/main.gd" "$DEST_DIR/scripts/main.gd"; then
  echo "ERRO: scripts/main.gd divergiu na pasta do Godot." >&2
  exit 1
fi
for asset in hud_bar.webp hud_controls.webp hud_icons.webp; do
  if [[ ! -s "$DEST_DIR/assets/hud/v3/$asset" ]]; then
    echo "ERRO: arte da HUD nao foi copiada: $asset" >&2
    exit 1
  fi
done

echo
echo "SINCRONIZACAO CONFIRMADA: commit $SHORT_REV"
echo "Versao registrada em: $DEST_DIR/CHAPOLIN_VERSAO.txt"
echo "IMPORTANTE: feche e reabra o editor Godot Android."
echo "Abra ESTE projeto: $DEST_DIR/project.godot"
echo "Se o editor mostrar uma copia antiga, remova-a apenas da lista de projetos"
echo "e importe o caminho acima (nao apague os arquivos)."
