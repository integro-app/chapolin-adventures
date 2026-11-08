#!/usr/bin/env bash
# Sincroniza a copia do Chapolin Adventures do GitHub para o Godot Android.
# Requer Termux: pkg install git rsync; termux-setup-storage.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="$HOME/storage/shared/Documents/ChapolinAdventures"

if [[ ! -d "$HOME/storage/shared" ]]; then
  echo "Acesso ao armazenamento nao configurado. Execute: termux-setup-storage" >&2
  exit 1
fi

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "Execute este script dentro do repositorio clonado com Git." >&2
  exit 1
fi

echo "Atualizando Chapolin Adventures pelo GitHub..."
git -C "$REPO_DIR" pull --ff-only
mkdir -p "$DEST_DIR"

# Mantem dados locais gerados pelo Godot, sem copiar o historico .git.
rsync -rt --delete --exclude='/.git/' --exclude='/.godot/' "$REPO_DIR/" "$DEST_DIR/"

echo "Sincronizado!"
echo "No Godot Android, abra: Documents/ChapolinAdventures/project.godot"
