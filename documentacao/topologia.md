# Topologia da Rede e Arquitetura da Infraestrutura

## 1. Visão Geral
A infraestrutura de rede foi planejada, implantada e consolidada para segmentar os serviços em três zonas de segurança isoladas: **DMZ**, **LAN** e **DB**. O controle de acesso e filtragem rígida de tráfego entre essas redes é realizado por uma máquina Firewall dedicada utilizando Ubuntu Server e o subsistema `nftables`.

## 2. Diagrama Lógico de Rede

```text
                             INTERNET / WAN
                                    |
                             [ FIREWALL ]
                             Ubuntu Server
                                    |
       +----------------------------+----------------------------+
       | (enp0s8)                   | (enp0s9)                   | (enp0s10)
       | 10.0.1.1/24                | 10.0.2.1/24                | 10.0.3.1/24
       v                            v                            v
+-------------------+        +-------------------+        +-------------------+
|     Zona DMZ      |        |     Zona LAN      |        |      Zona DB      |
|  Servidor Web     |        | Servidor Arquivos |        | Servidor DB       |
|  (Nginx / Flask)  |        |      (Samba)      |        |   (PostgreSQL)    |
|   IP: 10.0.1.10   |        |   IP: 10.0.2.10   |        |   IP: 10.0.3.10   |
+-------------------+        +-------------------+        +-------------------+

3. Interfaces do Firewall
Interface	Zona	Endereço IP / Máscara	Função / Estado
enp0s3	WAN	Obtido via DHCP	Conexão com a rede externa / Internet.
enp0s8	DMZ	10.0.1.1/24	Gateway da Zona Desmilitarizada.
enp0s9	LAN	10.0.2.1/24	Gateway da Rede Interna / Corporativa.
enp0s10	DB	10.0.3.1/24	Gateway da Zona de Banco de Dados.
4. Finalidade das Zonas e Serviços Alocados
WAN (enp0s3): Prover conectividade externa e permitir o mascaramento de IP (NAT) para saída da rede interna.

DMZ (10.0.1.0/24): Abriga o Servidor Web Nginx (10.0.1.10) atuando como Proxy Reverso para a aplicação Flask. É a única zona acessível publicamente via portas 80/443 TCP.

LAN (10.0.2.0/24): Destinada às estações administrativas e ao Servidor de Arquivos Samba (10.0.2.10). Possui permissão exclusiva de acesso via SSH (porta 22 TCP) para gerenciamento de todas as máquinas.

DB (10.0.3.0/24): Zona restrita onde reside o banco de dados PostgreSQL (10.0.3.10). Isolada de conexões externas e da LAN, aceitando conexões estritamente vindas da aplicação na DMZ (porta 5432 TCP).

5. Estado da Implementação
Concluído e Validado.

A máquina Firewall foi instalada, as 4 interfaces foram configuradas e as tabelas de roteamento foram habilitadas no kernel (net.ipv4.ip_forward=1).

Os servidores Nginx/Flask, Samba e PostgreSQL foram devidamente instalados e alocados em seus respetivos IPs estáticos.

As regras de firewall no nftables foram aplicadas com política padrão DROP, liberando apenas os fluxos validados na matriz de conectividade.

Os testes de comunicação (liberação do PostgreSQL para a DMZ e bloqueio total de tráfego não autorizado vindo da WAN) foram executados e homologados com sucesso.