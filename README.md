snap list
sudo snap install nextcloud
buscar ip do servidor no navegador (192...)

# Servidor Ubuntu: Samba, Nextcloud e DHCP

Este guia descreve como configurar um servidor Ubuntu para:

* Compartilhar arquivos com computadores Windows via Samba, com controle de permissões.
* Instalar e configurar o Nextcloud via Snap.
* Configurar um servidor DHCP usando `isc-dhcp-server`.

---

## Atualização do sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

## Samba: compartilhamento de arquivos Windows

### Instalar Samba

```bash
sudo apt install samba -y
```

### Criar pasta de arquivos

```bash
sudo mkdir -p /srv/arquivos
sudo chown -R usuario1:usuario1 /srv/arquivos
sudo chmod -R 770 /srv/arquivos
```

### Criar usuário Samba

```bash
sudo adduser usuario1
sudo smbpasswd -a usuario1
sudo smbpasswd -e usuario1
```

### Configurar compartilhamento

```bash
sudo nano /etc/samba/smb.conf
```

Adicione no final:

```ini
[Arquivos]
   path = /srv/arquivos
   browseable = yes
   read only = no
   valid users = usuario1
   force user = usuario1
```

### Reiniciar Samba

```bash
sudo systemctl restart smbd
sudo systemctl enable smbd
```

### Acessar do Windows

No Windows Explorer, digite:

```
\\192.168.0.110\Arquivos
```

Use o usuário e senha configurados (`usuario1`).

---

## Nextcloud: instalação via Snap

### Instalar Nextcloud

```bash
sudo snap install nextcloud
```

### Criar usuário administrador

Durante a instalação do Snap, crie o usuário e senha do Nextcloud.

### Configurar domínios confiáveis

```bash
sudo nano /var/snap/nextcloud/current/nextcloud/config/config.php
```

Edite a seção `trusted_domains`:

```php
'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => '192.168.0.110',
    2 => 'meudominio.com',
  ),
```

### Reiniciar Nextcloud

```bash
sudo snap restart nextcloud
```

### Acessar via navegador

```
http://192.168.0.110
```

ou pelo domínio configurado.

---

## Servidor DHCP

### Instalar servidor DHCP

```bash
sudo apt update
sudo apt install isc-dhcp-server -y
```

### Descobrir nome da interface LAN

```bash
ip addr
```

Exemplo: `enp0s3`, IP do servidor: `192.168.0.110`

### Configurar interface do DHCP

```bash
sudo nano /etc/default/isc-dhcp-server
```

Altere:

```
INTERFACESv4="enp0s3"
```

### Configurar escopo DHCP

```bash
sudo nano /etc/dhcp/dhcpd.conf
```

Exemplo:

```
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.100 192.168.0.200;
  option routers 192.168.0.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  option broadcast-address 192.168.0.255;
}
```

### Iniciar e habilitar serviço DHCP

```bash
sudo systemctl enable isc-dhcp-server
sudo systemctl start isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

### Testar conectividade (Windows)

```cmd
ping 192.168.0.110
```

### Ver DHCPs conectados

```bash
cat /var/lib/dhcp/dhcpd.leases
```

### Caso dê erro

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
ls -l /etc/dhcp/dhcpd.conf
sudo chmod 644 /etc/dhcp/dhcpd.conf
sudo chown root:root /etc/dhcp/dhcpd.conf
```

---

**Pronto!** Agora você tem um servidor Ubuntu com:

* Compartilhamento de arquivos Windows via Samba
* Nextcloud acessível pelo navegador
* Servidor DHCP fornecendo IPs para a rede
