# Projeto Prático Integrador — Infraestrutura de Redes e Servidores Linux

## 1. Sobre o projeto

Este projeto tem como objetivo projetar, implementar e documentar uma infraestrutura de redes e servidores Linux, aplicando conceitos de administração de sistemas operacionais, segmentação de redes, segurança, gerenciamento de serviços e automação.

A infraestrutura é dividida em três zonas de segurança: DMZ, LAN e DB. A comunicação entre essas redes é controlada por um firewall baseado em `nftables`.

O projeto contempla a implantação de servidores Web, banco de dados PostgreSQL e compartilhamento centralizado de arquivos, além de serviços de rede, políticas de segurança e rotinas de backup.

## 2. Arquitetura e segmentação da rede

A infraestrutura utiliza um firewall responsável pelo roteamento e controle do tráfego entre as redes.

| Zona | Sub-rede | Finalidade |
|---|---|---|
| WAN | Rede externa | Comunicação com a internet |
| DMZ | 10.0.1.0/24 | Servidor Web |
| LAN | 10.0.2.0/24 | Rede interna e compartilhamento de arquivos |
| DB | 10.0.3.0/24 | Servidor de banco de dados |

### 2.1. Servidores e endereçamento

| Equipamento | Endereço IP | Responsabilidade |
|---|---|---|
| FIREWALL | 10.0.1.1 / 10.0.2.1 / 10.0.3.1 | Roteamento e segurança entre as redes |
| SERVIDOR-WEB | 10.0.1.10 | Nginx e aplicação Flask |
| SERVIDOR-DB | 10.0.3.10 | PostgreSQL |

O firewall possui uma interface adicional conectada à rede externa (WAN).

## 3. Tecnologias utilizadas

- Ubuntu Server 26.04.1
- Oracle VirtualBox
- nftables
- Netplan
- OpenSSH
- Nginx
- OpenSSL
- Python
- Flask
- PostgreSQL 18
- psycopg
- python-dotenv
- Git e GitHub

## 4. Requisitos técnicos e desenvolvimento

### 4.1. Módulo de Redes e Serviços de Base

**Implementado:**

- [x] Instalação do Ubuntu Server na máquina FIREWALL.
- [x] Configuração das interfaces de rede.
- [x] Configuração das sub-redes DMZ, LAN e DB.
- [x] Configuração de endereços IP estáticos nos servidores Web e DB.
- [x] Instalação e ativação do OpenSSH.
- [x] Ativação do encaminhamento IPv4.
- [x] Instalação e configuração do nftables.
- [x] Definição da política padrão DROP na cadeia de encaminhamento.
- [x] Configuração de regras de encaminhamento entre as redes.
- [x] Configuração de NAT para acesso à internet pelas redes autorizadas.

**Pendente:**

- [ ] Instalação e configuração do serviço DHCP.
- [ ] Configuração de reservas de IP.
- [ ] Instalação e configuração do serviço DNS.
- [ ] Configuração de resolução direta e reversa para o domínio interno `empresa.local`.

### 4.2. Módulo M1 — Servidor Web (HTTP/HTTPS)

**Implementado:**

- [x] Instalação e configuração do Nginx.
- [x] Configuração do endereço IP estático do servidor Web.
- [x] Configuração de HTTPS com certificado autoassinado.
- [x] Redirecionamento de HTTP para HTTPS.
- [x] Configuração dos protocolos TLS 1.2 e TLS 1.3.
- [x] Configuração de logs de acesso e erro.
- [x] Configuração de Rate Limiting.
- [x] Ocultação da versão do servidor Nginx.
- [x] Configuração do Nginx como proxy reverso para a aplicação Flask.

**Pendente ou a validar:**

- [ ] Validar a configuração definitiva das páginas personalizadas de erro 404 e 500.
- [ ] Validar o acesso externo ao servidor pelas portas 80 e 443 através do firewall.

### 4.3. Módulo M2 — Servidor de Banco de Dados PostgreSQL

**Implementado:**

- [x] Instalação do PostgreSQL 18.
- [x] Configuração do endereço IP estático na rede DB.
- [x] Configuração do `postgresql.conf` para escutar na interface da rede DB.
- [x] Configuração do `pg_hba.conf` para permitir a conexão do servidor Web.
- [x] Configuração de autenticação SCRAM-SHA-256.
- [x] Criação do banco de dados `empresa_db`.
- [x] Criação do usuário de acesso à aplicação.
- [x] Criação da tabela `usuarios`.
- [x] Teste de conexão entre o servidor Web e o PostgreSQL.

**Pendente:**

- [ ] Revisão e documentação das permissões de privilégio mínimo.
- [ ] Criação de script de backup utilizando `pg_dump`.
- [ ] Configuração de execução automática do backup pelo Cron.
- [ ] Compactação dos arquivos de backup em `.tar.gz`.
- [ ] Envio dos backups para o servidor de arquivos.

### 4.4. Módulo M3 — Servidor de Arquivos Centralizado (Samba/NFS)

**Pendente:**

- [ ] Instalação e configuração do Samba ou NFS.
- [ ] Criação da estrutura hierárquica de diretórios compartilhados.
- [ ] Criação de grupos POSIX para controle de acesso.
- [ ] Configuração de permissões de leitura e escrita.
- [ ] Configuração de quotas de disco por usuário e grupo.
- [ ] Testes de compartilhamento e restrição de acesso.

## 5. Firewall e matriz de conectividade

O firewall utiliza `nftables`, com política padrão de bloqueio na cadeia de encaminhamento. As regras permitem somente os fluxos de comunicação configurados.

| Origem | Destino | Porta/Protocolo | Ação | Situação |
|---|---|---|---|---|
| WAN | Servidor Web (DMZ) | 80/443 TCP | Permitir | Pendente de regra e teste |
| Servidor Web (DMZ) | Servidor DB | 5432 TCP | Permitir | Implementado e testado |
| LAN | Servidor de Arquivos | 139/445 TCP | Permitir | Pendente |
| LAN (Admin) | Todas as zonas | 22 TCP | Permitir | Parcialmente configurado |
| DMZ/WAN | Servidor DB | Demais portas | Bloquear | Política padrão DROP |

### 5.1. Testes realizados

- [x] Teste de conexão do servidor Web com o PostgreSQL pela porta 5432.
- [x] Teste de bloqueio de conexão SSH do servidor Web para o servidor DB.
- [x] Verificação das regras da cadeia de encaminhamento do firewall.
- [x] Verificação do funcionamento do serviço PostgreSQL.
- [x] Verificação do funcionamento do Nginx e da aplicação Flask.

## 6. Aplicação Web de teste

Foi desenvolvida uma aplicação utilizando Python e Flask, integrada ao PostgreSQL, conforme o requisito de aplicação funcional de teste do projeto.

### Funcionalidades

- Cadastro de usuários com nome e e-mail.
- Armazenamento dos registros no PostgreSQL.
- Consulta dos usuários cadastrados.
- Exibição dos dados armazenados.

### Integração e funcionamento

O Nginx recebe as requisições HTTPS e encaminha as solicitações para a aplicação Flask, executada localmente na porta 5000.

A aplicação utiliza a biblioteca `psycopg` para estabelecer conexão com o PostgreSQL e a biblioteca `python-dotenv` para carregar as variáveis de ambiente.

O serviço Flask foi configurado no `systemd`, permitindo sua inicialização automática junto ao sistema.

## 7. Entregáveis obrigatórios

De acordo com o enunciado, o projeto possui três entregáveis principais.

### 7.1. Repositório Git

- [x] Repositório Git criado e disponibilizado.
- [x] Arquivos de configuração do firewall.
- [x] Arquivos de configuração do Nginx.
- [x] Arquivos de configuração do PostgreSQL.
- [x] Código-fonte da aplicação Web.
- [x] Arquivo de dependências da aplicação.
- [ ] Scripts Shell ou Playbooks Ansible para provisionamento automatizado da infraestrutura.
- [ ] Revisão final e documentação dos arquivos de configuração.

### 7.2. Relatório técnico integrado

- [ ] Diagrama visual da topologia com endereçamentos e nomes dos hosts.
- [ ] Tabelas de roteamento.
- [ ] Mapeamento de portas e regras de firewall.
- [ ] Procedimento operacional para restauração de backups.
- [ ] Procedimento para adição de novos usuários.
- [ ] Análise de segurança justificando a arquitetura adotada.

### 7.3. Defesa prática e demonstração

A apresentação deverá ter duração de 15 a 20 minutos por equipe, incluindo arguição individual e validação prática.

- [ ] Demonstrar o fluxo completo: acesso HTTPS, aplicação Web e gravação no PostgreSQL.
- [ ] Demonstrar o bloqueio de conexões não autorizadas ao banco de dados.
- [ ] Demonstrar o compartilhamento de arquivos Samba/NFS.
- [ ] Demonstrar restrições de escrita e quotas.
- [ ] Executar o script de backup e verificar a rotação dos arquivos no servidor de arquivos.

## 8. Estrutura do repositório

```text
Trabalho-de-Redes/
│
├── README.md
│
├── documentacao/
│   ├── enderecamento-ip.md
│   ├── firewall.md
│   └── topologia.md
│
├── firewall/
│   └── nftables.conf
│
├── web/
│   ├── aplicacao/
│   │   ├── app.py
│   │   └── requirements.txt
│   │
│   ├── html/
│   │   ├── index.html
│   │   ├── 404.html
│   │   └── 50x.html
│   │
│   ├── nginx/
│   │   ├── nginx.conf
│   │   └── nginx-default.conf
│   │
│   └── netplan/
│       └── 00-installer-config.yaml
│
└── db/
    ├── pg_hba.conf
    └── postgresql.conf
```

## 9. Segurança da infraestrutura

A arquitetura utiliza segmentação de rede para separar os serviços públicos, a rede interna e os dados armazenados no banco de dados.

O firewall controla a comunicação entre as zonas, enquanto o PostgreSQL restringe as conexões remotas ao servidor Web autorizado.

O servidor Web utiliza HTTPS com TLS 1.2 e TLS 1.3, e as credenciais da aplicação são armazenadas em variáveis de ambiente, não sendo publicadas no repositório.

## 10. Identificação do projeto

**Disciplina:** Redes de Computadores e Administração de Sistemas Operacionais.

**Modalidade:** Projeto Prático Integrador em equipe.

**Status:** Em desenvolvimento.
