#!/usr/bin/env bash
# Procedimento padrão para adicionar um novo usuário ao servidor de arquivos.
# Uso: sudo ./adicionar_usuario.sh <usuario> <grupo> [quota_soft_KB] [quota_hard_KB]
# Ex.: sudo ./adicionar_usuario.sh daniel devs
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Execute como root."; exit 1; }
[[ $# -ge 2 ]] || { echo "Uso: $0 <usuario> <grupo> [soft_KB] [hard_KB]"; exit 1; }

U="$1"; G="$2"
SOFT="${3:-512000}"; HARD="${4:-614400}"
MNT="$(df --output=target /srv/samba/compartilhado | tail -1)"

getent group "$G" >/dev/null || { echo "Grupo '$G' não existe (devs, diretoria, backup_mgr)."; exit 1; }
id "$U" >/dev/null 2>&1 && { echo "Usuário '$U' já existe."; exit 1; }

useradd -m -g "$G" -s /bin/bash "$U"
echo "Defina a senha Linux de $U:";  passwd "$U"
command -v smbpasswd >/dev/null 2>&1 && { echo "Defina a senha Samba de $U:"; smbpasswd -a "$U"; }
setquota -u "$U" "$SOFT" "$HARD" 5000 6000 "$MNT"

echo "Usuário criado:"; id "$U"; quota -u "$U"
