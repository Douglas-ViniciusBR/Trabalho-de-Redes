# Backup e restauração — Integrante 5

O módulo faz backup lógico completo de `empresa_db` (PostgreSQL 18).
Os cinco requisitos são: gerar backup, agendar, compactar, transferir e restaurar.

## Scripts e fluxo

| Arquivo | Função |
|---|---|
| `gerar_backup.sh` | No DB, exporta o banco e envia o pacote pela saída padrão (stdout). |
| `coletar_backup.sh` | No servidor de arquivos, busca por SSH, verifica e salva o pacote. |
| `restaurar_backup.sh` | No laboratório, restaura em banco de testes vazio após confirmação. |

`cron.example` traz o agendamento; `RELATORIO.md`, o resumo; `.gitignore` exclui backups e credenciais do Git.

```text
Arquivos: 10.0.2.10 (backup_user) -- inicia SSH/22 --> DB: 10.0.3.10 (pg_backup)
                               <-- retorna .tar.gz -- pg_dump empresa_db
Destino: /srv/samba/compartilhado/backups, compartilhado pelo Samba
```

O DB é acessado por socket local `/var/run/postgresql`, porta 5432.
O pacote `.tar.gz` contém somente `database.dump`, no formato custom do PostgreSQL.
O DB não precisa montar o compartilhamento Samba. A conexão começa na LAN;
a orientação inversa em `documentacao/servidor-arquivos.md` precisa ser alinhada pelo responsável.

## Pré-requisitos nas VMs

Os responsáveis devem preparar os itens abaixo; os scripts não instalam nem configuram serviços.

1. Disponibilizar Bash, GNU coreutils, GNU tar e gzip. No DB: `pg_dump` 18 e servidor SSH;
   no servidor de arquivos: cliente SSH e Cron; no laboratório: PostgreSQL, `pg_restore` e `psql` 18.
2. Copiar os scripts para `/opt/empresa-backup`, em UTF-8/LF, com dono root e sem escrita
   pelas contas executoras. Os comandos usam `/bin/bash` e dispensam permissão de execução.
3. No servidor de arquivos, preparar `backup_user`, grupo `backup_mgr` e o destino gravável,
   com espaço, quotas e suporte a hard links. Verificar também permissões e ACLs do Samba.
   Os backups são privados (0600); leitura pelo grupo depende da política dos responsáveis.
4. No DB, preparar a conta Linux `pg_backup`, sem sudo, e o papel PostgreSQL de mesmo nome,
   com LOGIN, sem superusuário e com autenticação local peer validada na VM.
   Conceder CONNECT no banco, USAGE nos schemas e SELECT nas tabelas e sequências,
   incluindo objetos futuros de cada dono. Revisar large objects e RLS, se houver.
5. Preparar a chave dedicada `/home/backup_user/.ssh/empresa_backup_ed25519` (0600)
   e a pasta `.ssh` (0700). No DB, autorizar a chave pública para `pg_backup`, restrita
   à origem `10.0.2.10` e ao comando `/bin/bash /opt/empresa-backup/gerar_backup.sh`.
   Antepor à chave pública em `authorized_keys`:
   `restrict,from="10.0.2.10",command="/bin/bash /opt/empresa-backup/gerar_backup.sh"`.
   A conta precisa de shell que execute esse comando; não guardar chaves no compartilhamento.
6. Conferir a fingerprint do DB por canal confiável e preparar
   `/home/backup_user/.ssh/known_hosts`. O SSH exige host conhecido e chave sem interação.
   Os comandos PostgreSQL também não pedem senha; se necessário, usar `.pgpass` externo
   ao repositório, com modo 0600, conforme autenticação aprovada. Não escrever senhas nos comandos.

## Executar, verificar e agendar

Após a preparação, executar no servidor de arquivos, como `backup_user`:

```bash
/bin/bash /opt/empresa-backup/coletar_backup.sh
```

Para demonstrar somente a geração, no DB, como `pg_backup`:

```bash
(umask 077; /bin/bash /opt/empresa-backup/gerar_backup.sh > "$HOME/ensaio.tar.gz")
```

Escolher um nome ainda inexistente. O `umask` no shell do redirecionamento torna o novo
arquivo privado; não corrige permissões de arquivo existente. Esse ensaio não transfere o pacote.
Na coleta normal, o sucesso mostra `Backup salvo: ...` e retorna código 0; falhas retornam outro código.
O coletor confere gzip, entrada única regular e assinatura do dump antes de salvar com nome único.
Backups anteriores são preservados. Essas verificações não comprovam recuperação dos dados.

Para agendar, o responsável usa `crontab -e` como `backup_user` e copia `cron.example`.
O modelo executa diariamente às **02:30, no horário local da VM**, sem coluna de usuário.
O `umask 077` antecede a criação de `/home/backup_user/coleta-backup.log`;
se o log já existir, conferir seu dono e modo 0600. Acompanhar o log e os arquivos gerados.

## Restaurar com segurança e conferir os dados

Usar somente instância isolada de laboratório, sem acesso à produção. Preparar um banco
vazio de `template0`, como `empresa_db_restore_aula`, pertencente a `restore_lab`, sem
superusuário. Reservá-lo para o ensaio, sem outros clientes criando objetos.
Copiar apenas pacote de origem confiável para o laboratório e conferir socket e porta.

```bash
/bin/bash /opt/empresa-backup/restaurar_backup.sh \
  /caminho/empresa_db_DATA_SUFIXO.tar.gz empresa_db_restore_aula \
  /var/run/postgresql 5432 restore_lab
```

Os argumentos são: pacote, banco de testes, socket local, porta e papel PostgreSQL.
Confirmar digitando o nome completo do banco. O script recusa `empresa_db`, nomes fora
de `empresa_db_restore_<id>` (letras minúsculas, números e sublinhado; máximo de 63 caracteres),
banco ocupado e papel superusuário ou que não seja dono. Aceita somente `public` vazio e `plpgsql` padrão.
Valida o pacote e o catálogo antes da confirmação; conecta ao banco somente após confirmação correta.
A restauração usa transação única, para em erro e não limpa nem cria bancos.

```bash
psql -X -h /var/run/postgresql -p 5432 -U restore_lab -d empresa_db_restore_aula
# Dentro do psql, usar o nome real da tabela:
\dt
\d public.NOME_REAL_DA_TABELA
SELECT count(*) FROM public.NOME_REAL_DA_TABELA;
```

Comparar estrutura, contagens e registros conhecidos com a origem; conferir chaves, índices, sequências e views. Repetir em outro banco vazio.

## Testes pendentes e limitações

Os testes locais registrados no relatório verificam sintaxe e comportamento com serviços simulados.
Ainda faltam validar nas VMs: contas, privilégios, autenticação local, SSH e firewall;
permissões e ACLs, espaço e quotas, Samba, execução real do Cron e privacidade do log;
dump e restauração PostgreSQL 18, comparando estrutura e dados. Não houve restauração real.
Ensaiar também pacote corrompido, confirmação errada, destino de produção ou ocupado e falha de autenticação.

Não há retenção automática, WAL/PITR (recuperação até um instante), backup de papéis globais,
criptografia em disco ou alertas. Donos, ACLs e tablespaces são omitidos na restauração de teste.
Só é aceito o pacote com um `database.dump`; gzip detecta corrupção acidental, não autentica a origem.
Coordenar execuções simultâneas e acompanhar disco, quotas e logs. Reservar espaço para dump e pacote;
quedas podem deixar temporários para análise manual. O nome do banco não garante isolamento do laboratório.
