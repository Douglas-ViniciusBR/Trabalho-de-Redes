#!/usr/bin/env bash
# Executar como backup_user no servidor de arquivos 10.0.2.10.
set -Eeuo pipefail
umask 077
export LC_ALL=C
erro() { echo "Erro: $*" >&2; exit 1; }
trap 'rc=$?; echo "Falha na coleta (código $rc)." >&2; exit "$rc"' ERR

destino=/srv/samba/compartilhado/backups
chave=/home/backup_user/.ssh/empresa_backup_ed25519
hosts=/home/backup_user/.ssh/known_hosts
[[ $# == 0 ]] || erro 'Uso: coletar_backup.sh'
[[ $(id -un) == backup_user ]] || erro 'Execute como backup_user.'
[[ -d $destino && ! -L $destino && -w $destino ]] || erro 'Destino indisponível.'
[[ -s $chave && -s $hosts ]] || erro 'Chave SSH e known_hosts devem ser provisionados.'

# Temporário privado no mesmo filesystem: nunca aparece como backup válido.
trabalho=$(mktemp -d "$destino/.coleta.XXXXXXXX")
limpar() {
    rm -f -- "$trabalho/pacote.part" "$trabalho/database.dump"
    rmdir -- "$trabalho"
}
trap limpar EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP
pacote=$trabalho/pacote.part

# LAN inicia SSH para o DB; BatchMode impede perguntas sob Cron.
echo 'Coletando de 10.0.3.10...'
ssh -F /dev/null -T -n -i "$chave" \
    -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes \
    -o "UserKnownHostsFile=$hosts" -o PasswordAuthentication=no \
    -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 \
    pg_backup@10.0.3.10 '/bin/bash /opt/empresa-backup/gerar_backup.sh' > "$pacote"

# Conferir gzip e aceitar somente um arquivo regular com nome conhecido.
gzip -t -- "$pacote"
conteudo=$(tar -tzf "$pacote")
[[ $conteudo == database.dump ]] || erro 'Conteúdo inesperado no pacote.'
listagem=$(tar -tvzf "$pacote")
[[ $listagem == -* && $listagem != *$'\n'* ]] || erro 'O dump deve ser arquivo regular.'
# -O envia o conteúdo à saída padrão: caminhos do tar nunca são extraídos.
tar -xOzf "$pacote" -- database.dump > "$trabalho/database.dump"
[[ $(head -c 5 -- "$trabalho/database.dump") == PGDMP ]] || erro 'Dump custom inválido.'

# O sufixo aleatório evita colisões; ln -T publica sem substituir arquivo algum.
nome="empresa_db_$(date -u +%Y%m%dT%H%M%SZ)_${trabalho##*.}.tar.gz"
ln -T -- "$pacote" "$destino/$nome"
echo "Backup salvo: $destino/$nome"
