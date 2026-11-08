#!/usr/bin/env bash
# =============================================================================
# Integrante 4 - Usuários, grupos POSIX, permissões e quotas de disco
# Só faz a parte do Integrante 4. NÃO instala pacotes de serviço, NÃO edita
# smb.conf, NÃO reinicia o Samba e NÃO cria os compartilhamentos
# (as pastas já devem existir, criadas pelo Integrante 3).
# Uso: sudo SENHA_INICIAL='TroqueEsta#123' ./setup_usuarios_permissoes.sh
# =============================================================================
set -euo pipefail

BASE="/srv/samba/compartilhado"     # caminho usado no smb.conf
GRUPOS=(devs diretoria backup_mgr)  # grupos usados no smb.conf

# usuario:grupo_principal
USUARIOS=(
  "ana:devs"
  "bruno:devs"
  "carla:diretoria"
  "backup_user:backup_mgr"
)

# Quotas em KB (soft/hard) e inodes (soft/hard)
QUOTA_USUARIO_SOFT=512000     # 500 MB
QUOTA_USUARIO_HARD=614400     # 600 MB
QUOTA_INODE_SOFT=5000
QUOTA_INODE_HARD=6000
QUOTA_BACKUP_SOFT=5242880     # 5 GB
QUOTA_BACKUP_HARD=6291456     # 6 GB
# Quotas por grupo (KB): grupo:soft:hard
QUOTAS_GRUPO=(
  "devs:2097152:2621440"          # 2 GB / 2,5 GB
  "diretoria:1048576:1310720"     # 1 GB / 1,25 GB
  "backup_mgr:10485760:12582912"  # 10 GB / 12 GB
)

[[ $EUID -eq 0 ]] || { echo "Execute como root (sudo)."; exit 1; }
: "${SENHA_INICIAL:?Defina SENHA_INICIAL (ex.: sudo SENHA_INICIAL='...' $0)}"
for d in publico projetos backups; do
  [[ -d "$BASE/$d" ]] || { echo "Pasta $BASE/$d não existe (criada pelo Integrante 3)."; exit 1; }
done

echo "[1/5] Instalando ferramentas de quota e ACL..."
apt-get install -y -qq quota acl >/dev/null
apt-get install -y -qq "linux-modules-extra-$(uname -r)" >/dev/null 2>&1 || true

echo "[2/5] Criando grupos POSIX..."
for g in "${GRUPOS[@]}"; do
  getent group "$g" >/dev/null || groupadd "$g"
done

echo "[3/5] Criando usuários..."
for item in "${USUARIOS[@]}"; do
  u="${item%%:*}"; g="${item##*:}"
  id "$u" >/dev/null 2>&1 || useradd -m -g "$g" -s /bin/bash "$u"
  echo "$u:$SENHA_INICIAL" | chpasswd
  # senha Samba só se o Samba já estiver instalado (não instalamos nada dele)
  if command -v smbpasswd >/dev/null 2>&1; then
    printf '%s\n%s\n' "$SENHA_INICIAL" "$SENHA_INICIAL" | smbpasswd -s -a "$u" >/dev/null
  fi
done

echo "[4/5] Permissões de leitura e escrita nas pastas..."
chown nobody:nogroup "$BASE/publico";  chmod 2775 "$BASE/publico"
chown root:devs "$BASE/projetos";      chmod 2770 "$BASE/projetos"
setfacl -m    g:diretoria:rwx "$BASE/projetos"
setfacl -d -m g:diretoria:rwx "$BASE/projetos"
setfacl -d -m g:devs:rwx      "$BASE/projetos"
chown root:backup_mgr "$BASE/backups"; chmod 2770 "$BASE/backups"

echo "[5/5] Quotas de disco..."
MNT="$(df --output=target "$BASE" | tail -1)"
if ! findmnt -no OPTIONS "$MNT" | grep -q usrquota; then
  cp /etc/fstab "/etc/fstab.bak.$(date +%F-%H%M)"
  awk -v m="$MNT" '
    $1 !~ /^#/ && $2 == m && $4 !~ /usrquota/ { $4 = $4",usrquota,grpquota" }
    { print }' /etc/fstab > /etc/fstab.new && mv /etc/fstab.new /etc/fstab
  mount -o remount "$MNT"
fi
quotaoff -ug "$MNT" 2>/dev/null || true
quotacheck -cugm "$MNT" || quotacheck -cugmf "$MNT"
quotaon -ug "$MNT"

for item in "${USUARIOS[@]}"; do
  u="${item%%:*}"
  if [[ "$u" == "backup_user" ]]; then
    setquota -u "$u" $QUOTA_BACKUP_SOFT $QUOTA_BACKUP_HARD $QUOTA_INODE_SOFT $QUOTA_INODE_HARD "$MNT"
  else
    setquota -u "$u" $QUOTA_USUARIO_SOFT $QUOTA_USUARIO_HARD $QUOTA_INODE_SOFT $QUOTA_INODE_HARD "$MNT"
  fi
done
for item in "${QUOTAS_GRUPO[@]}"; do
  IFS=: read -r g gs gh <<< "$item"
  setquota -g "$g" "$gs" "$gh" 0 0 "$MNT"
done
setquota -t 604800 604800 "$MNT"

echo; echo "Concluído."; repquota -s "$MNT" | head -20
