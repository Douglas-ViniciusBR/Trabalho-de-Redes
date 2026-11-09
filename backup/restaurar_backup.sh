#!/usr/bin/env bash
# Usar somente instância isolada e papel exclusivo de laboratório.
set -Eeuo pipefail
umask 077
export LC_ALL=C
erro() { echo "Erro: $*" >&2; exit 1; }
trap 'rc=$?; echo "Falha na restauração (código $rc)." >&2; exit "$rc"' ERR

[[ $# == 5 ]] || erro 'Uso: restaurar_backup.sh PACOTE BANCO_TESTE SOCKET PORTA PAPEL'
pacote=$1 banco=$2 socket=$3 porta=$4 papel=$5
[[ -f $pacote && ! -L $pacote && -s $pacote ]] || erro 'Backup ausente, vazio ou link.'
[[ $banco != empresa_db && $banco =~ ^empresa_db_restore_[a-z0-9_]+$ && ${#banco} -le 63 ]] \
    || erro 'Use somente empresa_db_restore_<identificador>; produção é proibida.'
[[ $socket == /* && $socket != / && $socket != *$'\n'* ]] || erro 'Informe o socket local do laboratório.'
[[ $porta =~ ^[1-9][0-9]{0,4}$ ]] && (( porta <= 65535 )) || erro 'Porta inválida.'
[[ $papel =~ ^[a-z_][a-z0-9_]{0,62}$ ]] || erro 'Papel inválido.'

trabalho=$(mktemp -d "${TMPDIR:-/var/tmp}/empresa-restaurar.XXXXXXXX")
limpar() {
    rm -f -- "$trabalho/database.dump"
    rmdir -- "$trabalho"
}
trap limpar EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP

gzip -t -- "$pacote"
conteudo=$(tar -tzf "$pacote")
[[ $conteudo == database.dump ]] || erro 'Conteúdo inesperado no pacote.'
listagem=$(tar -tvzf "$pacote")
[[ $listagem == -* && $listagem != *$'\n'* ]] || erro 'O dump deve ser arquivo regular.'
# Extrair somente os bytes para um nome fixo dentro do temporário privado.
tar -xOzf "$pacote" -- database.dump > "$trabalho/database.dump"
pg_restore --list "$trabalho/database.dump" > /dev/null

echo "Destino: $banco; socket: $socket; porta: $porta; papel: $papel."
read -r -p "Confirme digitando o nome do banco de testes: " confirmacao || erro 'Confirmação ausente.'
[[ $confirmacao == "$banco" ]] || erro 'Confirmação incorreta; nada restaurado.'
unset PGHOST PGHOSTADDR PGSERVICE PGSERVICEFILE PGDATABASE PGUSER PGPASSWORD PGOPTIONS
export PGCONNECT_TIMEOUT=10
conexao=(--no-password --host="$socket" --port="$porta" --username="$papel" --dbname="$banco")

# Não basta contar tabelas: funções, tipos e outros objetos também ocupam o banco.
# Aceitar apenas public vazio e plpgsql padrão, com papel não superusuário/dono.
vazio=$(PGOPTIONS='-c default_transaction_read_only=on -c statement_timeout=60000' \
    psql -X --set=ON_ERROR_STOP=1 "${conexao[@]}" -Atc "
SELECT current_database() = '$banco'
 AND NOT (SELECT rolsuper FROM pg_roles WHERE rolname = current_user)
 AND (SELECT pg_get_userbyid(datdba) = current_user FROM pg_database WHERE datname = current_database())
 AND NOT EXISTS (
 SELECT 1 FROM pg_namespace n WHERE n.nspname !~ '^pg_' AND n.nspname <> 'information_schema'
 AND (n.nspname <> 'public' OR EXISTS (SELECT 1 FROM pg_depend d
 WHERE d.refclassid='pg_namespace'::regclass AND d.refobjid=n.oid)))
 AND NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname <> 'plpgsql')
 AND NOT EXISTS (SELECT 1 FROM pg_largeobject_metadata)
 AND NOT EXISTS (SELECT 1 FROM pg_event_trigger)
 AND NOT EXISTS (SELECT 1 FROM pg_foreign_data_wrapper)
 AND NOT EXISTS (SELECT 1 FROM pg_foreign_server)
 AND NOT EXISTS (SELECT 1 FROM pg_default_acl)
 AND NOT EXISTS (SELECT 1 FROM pg_seclabel)
 AND NOT EXISTS (SELECT 1 FROM pg_transform)
 AND NOT EXISTS (SELECT 1 FROM pg_cast WHERE oid >= 16384)
 AND NOT EXISTS (SELECT 1 FROM pg_language WHERE lanname NOT IN ('internal','c','sql','plpgsql'))
 AND NOT EXISTS (SELECT 1 FROM pg_publication)
 AND NOT EXISTS (SELECT 1 FROM pg_subscription
 WHERE subdbid = (SELECT oid FROM pg_database WHERE datname = current_database()));")
[[ $vazio == t ]] || erro 'Destino ocupado ou papel inadequado; restauração recusada.'

# Sem --clean/--create: nada é apagado. Erros interrompem a transação inteira.
pg_restore "${conexao[@]}" --exit-on-error --single-transaction \
    --no-owner --no-privileges --no-tablespaces "$trabalho/database.dump"
echo "Restauração concluída em $banco. Confira tabelas e dados conforme o README."
