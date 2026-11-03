# Trabalho de Redes — Infraestrutura e Servidores Linux

## Sobre o projeto

Este projeto tem como objetivo desenvolver e implementar uma infraestrutura de redes e servidores Linux, aplicando conceitos de administração de sistemas operacionais, segurança de redes e gerenciamento de serviços.

A infraestrutura será dividida em três zonas de segurança: DMZ, LAN e DB, utilizando um firewall para controlar a comunicação entre elas.

## Arquitetura da rede

| Zona | Sub-rede | Finalidade |
|---|---|---|
| WAN | Rede externa | Acesso à internet |
| DMZ | 10.0.1.0/24 | Servidor Web |
| LAN | 10.0.2.0/24 | Rede interna e compartilhamento de arquivos |
| DB | 10.0.3.0/24 | Servidor de banco de dados |

## Tecnologias utilizadas

- Ubuntu Server
- VirtualBox
- nftables
- OpenSSH
- Nginx (planejado)
- PostgreSQL (planejado)
- Samba (planejado)
- Git e GitHub

## Progresso do desenvolvimento

### Etapa 1 — Infraestrutura inicial

- [x] Instalação do Ubuntu Server na máquina FIREWALL.
- [x] Configuração das interfaces de rede.
- [x] Configuração dos endereços IP das zonas.
- [x] Instalação e ativação do serviço SSH.
- [x] Ativação do encaminhamento IPv4.
- [x] Instalação do nftables.
- [x] Verificação inicial do arquivo de configuração do firewall.

### Próximas etapas

- [ ] Implementação das regras de firewall.
- [ ] Configuração dos serviços DHCP e DNS.
- [ ] Implantação do servidor Web com HTTPS.
- [ ] Instalação e configuração do PostgreSQL.
- [ ] Configuração do servidor de arquivos Samba.
- [ ] Implementação dos scripts de backup.
- [ ] Testes de segurança e conectividade.
- [ ] Elaboração do relatório técnico.

## Estrutura do repositório

Os arquivos de configuração, scripts, documentação e código-fonte serão organizados neste repositório conforme o desenvolvimento do projeto.

## Disciplina

Redes de Computadores e Administração de Sistemas Operacionais.

**Projeto em desenvolvimento.**
