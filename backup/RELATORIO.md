# Backup e restauração — relatório do Integrante 5

O módulo tem como objetivo proteger o banco `empresa_db` por meio de backup lógico
completo e permitir o ensaio de recuperação em ambiente de laboratório.

Foram utilizados Bash, PostgreSQL 18 (`pg_dump`, `pg_restore` e `psql`),
OpenSSH, GNU tar, gzip e Cron. As contas executoras usam permissões limitadas.

O servidor de arquivos `10.0.2.10`, com a conta `backup_user`, inicia uma conexão
SSH para `10.0.3.10`. No DB, `pg_backup` exporta o banco por socket local.
O dump em formato custom é compactado em `.tar.gz` e retorna pela mesma conexão.
O coletor verifica o pacote e o salva em `/srv/samba/compartilhado/backups`,
compartilhado pelo Samba, com nome único e sem substituir cópias anteriores.

O modelo de Cron prevê execução diária às 02:30, no horário local da VM.
O comando usa `umask 077` antes do redirecionamento para criar o log privado.
O agendamento ainda depende de instalação e validação pelo responsável.

A restauração exige pacote confiável, instância isolada e banco de testes vazio,
criado de `template0`, com papel proprietário sem superusuário e confirmação do nome.
O script recusa produção e destinos ocupados. A execução ocorre em transação única,
sem limpar ou criar bancos; estrutura e dados devem ser comparados com a origem.

Os testes locais registrados verificaram a sintaxe dos três scripts, compactação,
leitura e preservação dos arquivos, com simulações de PostgreSQL e SSH.
Também foram verificadas falhas de execução, pacotes inválidos e confirmação incorreta.
Esses ensaios não comprovam recuperação de dados; não houve restauração real.

Permanecem pendentes nas VMs: contas, privilégios, autenticação local, SSH e firewall,
permissões e ACLs, espaço e quotas, Samba, Cron e privacidade do log, além de dump e
restauração PostgreSQL 18 com comparação de estrutura e dados e ensaios de falhas.

O módulo não oferece retenção automática, WAL/PITR, papéis globais, criptografia
em disco ou alertas. A restauração de teste omite donos, ACLs e tablespaces.
Isolamento, concorrência, espaço disponível, logs e cópias antigas exigem acompanhamento.
