# Projeto Prático Integrador — Infraestrutura de Redes e Servidores Linux

## 1. Sobre o projeto

Este projeto tem como objetivo projetar, implementar e documentar uma infraestrutura de redes e servidores Linux, aplicando conceitos de administração de sistemas operacionais, segmentação de redes, segurança, gerenciamento de serviços e automação.

A infraestrutura foi desenvolvida utilizando máquinas virtuais no Oracle VirtualBox e organizada em três zonas de segurança: DMZ, LAN e DB. A comunicação entre essas redes é controlada por um firewall baseado em `nftables`.

O ambiente contempla serviços de rede, servidor Web, banco de dados PostgreSQL, aplicação Web integrada, compartilhamento centralizado de arquivos, gerenciamento de usuários e permissões, além de rotinas de backup e procedimentos de administração.

## 2. Arquitetura e segmentação da rede

A infraestrutura utiliza um firewall responsável pelo roteamento e controle do tráfego entre as redes.

| Zona | Sub-rede | Finalidade |
|---|---|---|
| WAN | Rede externa | Comunicação com a internet |
| DMZ | `10.0.1.0/24` | Hospedagem do servidor Web |
| LAN | `10.0.2.0/24` | Rede interna, serviços de rede e compartilhamento |
| DB | `10.0.3.0/24` | Isolamento do servidor de banco de dados |

### 2.1. Servidores e endereçamento

| Equipamento | Endereço IP | Responsabilidade |
|---|---|---|
| FIREWALL | `10.0.1.1` / `10.0.2.1` / `10.0.3.1` | Roteamento e segurança entre as redes |
| SERVIDOR-WEB | `10.0.1.10` | Nginx, HTTPS e aplicação Flask |
| SERVIDOR-DB | `10.0.3.10` | PostgreSQL |
| SERVIDOR DHCP/DNS | Conforme configuração do ambiente | Distribuição de IPs e resolução de nomes |
| SERVIDOR DE ARQUIVOS | Conforme configuração do ambiente | Compartilhamento centralizado de arquivos |

O firewall possui uma interface adicional conectada à rede externa (WAN). Os servidores Web e DB utilizam endereços IP estáticos.

## 3. Tecnologias utilizadas

- Ubuntu Server 26.04.1
- Oracle VirtualBox
- nftables
- Netplan
- OpenSSH
- DHCP
- DNS / Bind9
- Nginx
- OpenSSL
- Python
- Flask
- PostgreSQL 18
- psycopg
- python-dotenv
- Samba ou NFS
- Shell Script
- Cron
- Git e GitHub

## 4. Desenvolvimento e módulos implementados

### 4.1. Módulo de Redes e Serviços de Base

Responsável: **Integrante 1**

- Instalação e configuração do Ubuntu Server na máquina FIREWALL.
- Configuração das interfaces de rede.
- Segmentação das redes DMZ, LAN e DB.
- Configuração de endereços IP estáticos.
- Instalação e configuração do OpenSSH.
- Ativação do encaminhamento IPv4.
- Instalação e configuração do firewall com nftables.
- Definição da política padrão DROP na cadeia de encaminhamento.
- Configuração das regras de comunicação entre as zonas.
- Configuração de NAT para acesso à internet pelas redes autorizadas.

### 4.2. Módulo M1 — Servidor Web (HTTP/HTTPS)

Responsável: **Integrante 1**

- Instalação e configuração do Nginx.
- Configuração do endereço IP estático do servidor Web.
- Configuração de HTTPS com certificado autoassinado.
- Redirecionamento de HTTP para HTTPS.
- Utilização dos protocolos TLS 1.2 e TLS 1.3.
- Configuração dos logs de acesso e erro.
- Configuração de Rate Limiting.
- Ocultação da versão do servidor Nginx.
- Configuração do Nginx como proxy reverso para a aplicação Flask.

### 4.3. Módulo M2 — Servidor de Banco de Dados PostgreSQL

Responsável: **Integrante 1**

- Instalação e configuração do PostgreSQL 18.
- Configuração do endereço IP estático na rede DB.
- Configuração do `postgresql.conf` para escutar na interface da rede DB.
- Configuração do `pg_hba.conf` para restringir as conexões autorizadas.
- Configuração de autenticação SCRAM-SHA-256.
- Criação do banco de dados `empresa_db`.
- Criação do usuário de acesso da aplicação.
- Criação da tabela `usuarios`.
- Integração com a aplicação Flask.
- Teste de comunicação entre o servidor Web e o PostgreSQL.

### 4.4. Módulo M3 — DHCP e DNS

Responsável: **Integrante 2**

- Instalação e configuração dos serviços DHCP e DNS.
- Configuração da distribuição dinâmica de endereços IP na rede interna.
- Configuração de reservas de IP.
- Configuração do domínio interno `empresa.local`.
- Configuração de resolução direta de nomes.
- Configuração de resolução reversa.
- Testes de distribuição de endereços e resolução de nomes.

### 4.5. Módulo M4 — Servidor de Arquivos Centralizado

Responsável: **Integrante 3**

- Instalação e configuração do serviço de compartilhamento de arquivos.
- Implantação do Samba ou NFS.
- Criação da estrutura hierárquica de diretórios compartilhados.
- Configuração dos compartilhamentos da rede interna.
- Configuração de acesso aos diretórios.
- Testes de leitura, escrita e restrição de acesso.

### 4.6. Módulo M5 — Gerenciamento de Usuários e Permissões

Responsável: **Integrante 4**

- Criação e gerenciamento de usuários Linux.
- Criação de grupos POSIX.
- Organização dos usuários conforme seus grupos.
- Configuração de permissões de leitura e escrita.
- Aplicação de restrições de acesso aos diretórios.
- Configuração de quotas de disco por usuário e/ou grupo.
- Testes de permissões e limites de armazenamento.

### 4.7. Módulo M6 — Backup e Restauração

Responsável: **Integrante 5**

- Desenvolvimento de script automatizado para backup do PostgreSQL.
- Utilização do `pg_dump` para exportação dos dados.
- Configuração de execução automática utilizando Cron.
- Compactação dos arquivos de backup em formato `.tar.gz`.
- Armazenamento dos backups no servidor de arquivos.
- Organização e rotação dos arquivos de backup.
- Testes de restauração dos dados.

### 4.8. Módulo M7 — Automação, Documentação e Integração

Responsável: **Integrante 6**, com colaboração dos demais integrantes.

- Organização dos scripts de automação da infraestrutura.
- Consolidação dos arquivos de configuração.
- Organização da documentação técnica.
- Elaboração do diagrama de topologia da rede.
- Consolidação das informações de endereçamento e conectividade.
- Organização do relatório técnico.
- Revisão da estrutura do repositório GitHub.
- Apoio à integração dos serviços e aos testes finais.
- Organização da apresentação e da demonstração prática.

## 5. Firewall e matriz de conectividade

O firewall utiliza `nftables`, com política padrão de bloqueio na cadeia de encaminhamento. O tráfego entre as zonas é controlado por regras específicas, permitindo somente as comunicações autorizadas.

| Origem | Destino | Porta/Protocolo | Finalidade |
|---|---|---|---|
| WAN | Servidor Web (DMZ) | 80/443 TCP | Acesso HTTP/HTTPS |
| Servidor Web (DMZ) | Servidor DB | 5432 TCP | Comunicação com PostgreSQL |
| LAN | Servidor de Arquivos | 139/445 TCP ou portas NFS | Compartilhamento de arquivos |
| LAN (Admin) | Servidores autorizados | 22 TCP | Administração por SSH |
| DMZ/WAN | Servidor DB | Demais portas não autorizadas | Bloqueio de acesso |

As regras efetivamente aplicadas e os respectivos testes estão documentados nos arquivos de configuração e na documentação técnica do projeto.

## 6. Aplicação Web de teste

Foi desenvolvida uma aplicação utilizando Python e Flask, integrada ao PostgreSQL, para demonstrar o funcionamento da comunicação entre o servidor Web e o banco de dados.

### 6.1. Funcionalidades

- Cadastro de usuários com nome e e-mail.
- Armazenamento dos registros no PostgreSQL.
- Consulta dos usuários cadastrados.
- Exibição dos dados armazenados.

### 6.2. Integração e funcionamento

O Nginx recebe as requisições HTTPS e encaminha as solicitações para a aplicação Flask, executada localmente na porta 5000.

A aplicação utiliza a biblioteca `psycopg` para estabelecer conexão com o PostgreSQL e `python-dotenv` para carregar as variáveis de ambiente.

O serviço Flask foi configurado no `systemd`, permitindo sua inicialização automática junto ao sistema.

O fluxo de funcionamento é:

1. O usuário acessa o servidor Web por HTTPS.
2. O Nginx recebe a requisição.
3. A solicitação é encaminhada para a aplicação Flask.
4. A aplicação realiza a operação no PostgreSQL.
5. Os dados são armazenados ou consultados no banco de dados.
6. O resultado é apresentado ao usuário.

## 7. Testes e validações

Durante o desenvolvimento e a integração, foram realizados testes para verificar o funcionamento dos serviços e as políticas de segurança.

Entre as validações do ambiente estão:

- Comunicação entre as redes por meio do firewall.
- Verificação das regras de encaminhamento do nftables.
- Teste de conexão do servidor Web com o PostgreSQL pela porta 5432.
- Teste de bloqueio de conexão SSH não autorizada do servidor Web para o servidor DB.
- Verificação do funcionamento do PostgreSQL.
- Verificação do funcionamento do Nginx e da aplicação Flask.
- Testes de distribuição de endereços e resolução DNS.
- Testes de compartilhamento e permissões de arquivos.
- Testes de quotas de armazenamento.
- Execução e validação dos procedimentos de backup e restauração.

## 8. Segurança da infraestrutura

A arquitetura utiliza segmentação de rede para separar os serviços Web, a rede interna e os dados armazenados no banco de dados.

As principais medidas de segurança adotadas incluem:

- Separação das zonas WAN, DMZ, LAN e DB.
- Controle de tráfego por meio do firewall nftables.
- Política padrão DROP na cadeia de encaminhamento.
- Restrição das conexões ao PostgreSQL por meio do `pg_hba.conf`.
- Autenticação SCRAM-SHA-256 no PostgreSQL.
- Comunicação HTTPS com TLS 1.2 e TLS 1.3.
- Ocultação da versão do servidor Nginx.
- Limitação de requisições por Rate Limiting.
- Controle de acesso aos arquivos por usuários, grupos e permissões.
- Armazenamento de credenciais da aplicação em variáveis de ambiente, sem publicação no repositório.
- Rotinas de backup para proteção e recuperação dos dados.

## 9. Estrutura do repositório

O repositório reúne os arquivos de configuração, códigos-fonte, scripts de automação e documentação utilizados na infraestrutura.

```text
Trabalho-de-Redes/
│
├── README.md
│
├── documentacao/
│   ├── enderecamento-ip.md
│   ├── firewall.md
│   ├── topologia.md
│   └── ...
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
├── db/
│   ├── pg_hba.conf
│   └── postgresql.conf
│
├── dhcp-dns/
│   └── ...
│
├── servidor-arquivos/
│   └── ...
│
├── usuarios-permissoes/
│   └── ...
│
├── backup/
│   └── ...
│
└── automacao/
    └── ...
```

*Observação: os diretórios indicados com `...` representam os arquivos específicos dos demais módulos. A estrutura deve acompanhar os nomes e caminhos efetivamente utilizados no repositório.*

## 10. Entregáveis do projeto

### 10.1. Repositório Git

O repositório GitHub reúne os arquivos necessários para documentar e reproduzir a infraestrutura, incluindo:

- Arquivos de configuração dos serviços.
- Configuração do firewall e das interfaces de rede.
- Configurações do servidor Web e do PostgreSQL.
- Código-fonte da aplicação Flask.
- Arquivos de dependências.
- Scripts de automação e backup.
- Configurações dos serviços de rede e compartilhamento.
- Documentação técnica.

**Repositório:** https://github.com/Douglas-ViniciusBR/Trabalho-de-Redes

### 10.2. Relatório técnico

O relatório técnico reúne a documentação da infraestrutura implementada, contemplando:

- Diagrama visual da topologia da rede.
- Endereçamento IP e identificação dos hosts.
- Tabelas de roteamento.
- Mapeamento de portas e regras de firewall.
- Procedimento operacional para restauração de backups.
- Procedimento para adição de novos usuários.
- Análise de segurança e justificativa da arquitetura.
- Descrição dos serviços e configurações implementados.

### 10.3. Defesa prática e demonstração

A apresentação prática contempla a demonstração dos principais serviços da infraestrutura:

- Acesso HTTPS ao servidor Web.
- Funcionamento da aplicação Flask.
- Cadastro e consulta de registros no PostgreSQL.
- Bloqueio de conexões não autorizadas ao banco de dados.
- Distribuição de endereços IP e resolução DNS.
- Compartilhamento de arquivos.
- Validação das permissões de usuários e grupos.
- Verificação das quotas de armazenamento.
- Execução do script de backup e verificação dos arquivos gerados.
- Demonstração dos procedimentos de restauração.

## 11. Divisão de responsabilidades da equipe

| Integrante | Responsabilidades |
|---|---|
| Douglas Vinícius | Firewall, infraestrutura de rede, Nginx, HTTPS, PostgreSQL e aplicação Flask |
| Lucas Oliveira | DHCP, DNS, reservas de IP e domínio interno `empresa.local` |
| Joalysson | Servidor de arquivos Samba/NFS e compartilhamentos |
| Gustavo | Usuários, grupos POSIX, permissões e quotas |
| Lucas | Backup PostgreSQL, Cron, compactação e restauração |
| Marcus Vinícius | Automação, organização do GitHub, documentação, integração e apresentação |

Todos os integrantes contribuíram para a implementação, documentação e integração dos respectivos módulos.

## 12. Considerações finais

O projeto permitiu aplicar, em um ambiente virtualizado, conhecimentos de administração Linux, infraestrutura de redes, segmentação de ambientes, segurança, serviços Web, bancos de dados, compartilhamento de arquivos e automação.

A integração dos módulos resultou em uma infraestrutura organizada em zonas de segurança, com serviços independentes e comunicação controlada pelo firewall.

Além da implementação técnica, o trabalho proporcionou experiência prática de colaboração em equipe, documentação, resolução de problemas e integração de serviços em servidores Linux.

---

**Disciplina:** Redes de Computadores do Professor Ricardo

**Modalidade:** Projeto Prático Integrador em equipe.

**Status:** Concluído — implementação, integração e documentação do projeto.
