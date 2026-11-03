# Topologia da Rede

## 1. Visão geral

A infraestrutura de rede foi planejada para separar os serviços em três zonas de segurança: DMZ, LAN e DB.

O controle da comunicação entre essas redes será realizado por uma máquina Firewall utilizando Ubuntu Server e nftables.

## 2. Diagrama lógico

```text
              INTERNET
                  |
             [ FIREWALL ]
              Ubuntu Server
                  |
       +----------+----------+
       |          |          |
      DMZ        LAN         DB
  10.0.1.0/24 10.0.2.0/24 10.0.3.0/24
       |          |          |
   Servidor    Servidor    Servidor
     Web       de Arquivos  PostgreSQL
   (Nginx)      (Samba)    (Banco de Dados)
```

## 3. Interfaces do Firewall

| Interface | Zona | Endereço IP |
|---|---|---|
| enp0s3 | WAN | Obtido via DHCP |
| enp0s8 | DMZ | 10.0.1.1/24 |
| enp0s9 | LAN | 10.0.2.1/24 |
| enp0s10 | DB | 10.0.3.1/24 |

## 4. Finalidade das zonas

- **WAN:** conexão com a rede externa e internet.
- **DMZ:** destinada ao servidor Web, que disponibilizará a aplicação.
- **LAN:** destinada aos usuários internos e ao compartilhamento de arquivos.
- **DB:** destinada ao servidor PostgreSQL, mantendo os dados isolados das demais redes.

## 5. Estado da implementação

Até o momento, a máquina Firewall foi instalada e suas quatro interfaces de rede foram configuradas.

Os servidores Web, de arquivos e de banco de dados ainda serão implantados nas próximas etapas.

**Documento em desenvolvimento.**
