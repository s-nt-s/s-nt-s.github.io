Title: Notificaciones xmmp desde Linux
Date: 2014-08-01 15:11
Category: Sistemas
Slug: notificaciones-xmmp-desde-linux

Tags: linux, transmission, xmpp, ssh

**Problema**: Queremos tener un comando sencillo que usar en nuestros
script para mandarnos notificaciones

**Solución**: usar xmpp y crear un grupo con permisos para usar este
comando

**1-** Instalar sendxmpp y crear comando

```console
pi@bot ~ $ sudo apt-get install sendxmpp
...
pi@bot ~ $ sudo touch /usr/local/bin/say
pi@bot ~ $ sudo chmod 710 /usr/local/bin/say
pi@bot ~ $ sudo nano /usr/local/bin/say
```

```bash
#!/bin/bash
echo "$*" | sendxmpp -u usuario -p contraseña -j servidor_jabber -o dominio -t destinatario

#Ejemplo con gmail:
#sendxmpp -t -u mygmailuser -o gmail.com -p mygmailpassword another@jabber.com
```

**Nota**: Creamos este script como root (sudo) ya que contiene el
usuario y contraseña de la cuenta que usamos para enviar y la derección
de a quien queremos que se le envíen los mensajes que usen este comando.
Ahora bien, probablemente queremos que el comando este disponible para
usuarios que no queremos que sean sudo ni puedan leer el codigo del
script, para ello veremos los siguientes pasos

**2-** Crear grupo que podrá enviar mensajes y darle permisos para
ejecutar el comando

```console
pi@bot ~ $ sudo groupadd snd
pi@bot ~ $ sudo visudo
```

```
[...]
%snd    ALL = NOPASSWD: /usr/local/bin/say
```

**3-** Ejemplo con transmission: aviso de descarga finalizada.

```console
pi@bot ~ $ sudo adduser debian-transmission snd
pi@bot ~ $ nano /dwn/complete.sh
```

```bash
#!/bin/bash
sudo say DECARGADO: "$TR_TORRENT_NAME"
```

```console
pi@bot ~ $ sudo service transmission-daemon stop
pi@bot ~ $ sudo nano /var/lib/transmission-daemon/info/settings.json
```

```json
{
...
    "script-torrent-done-filename": "/dwn/complete.sh",
...
}
```

```console
pi@bot ~ $ sudo service transmission-daemon start
```

**4-** Ejemplo con PAM: aviso de usuario conectado por ssh.

```console
pi@bot ~/wks/scripts $ touch notif-login.sh
pi@bot ~/wks/scripts $ chmod +x notif-login.sh
pi@bot ~/wks/scripts $ nano notif-login.sh
```

```bash
#!/bin/bash
if [ "$PAM_TYPE" != "open_session" ]; then
	exit 0
fi
if [ "${PAM_RHOST:0:10}" = "192.168.1." ]; then
	exit 0
fi

USER="$PAM_USER@$PAM_RHOST"
if [ -z "$PAM_RHOST" ]; then
	USER="$PAM_USER"
fi

sudo say $(date "+%d/%m/%Y %H:%M")" > $USER inicia $PAM_SERVICE en TTY $PAM_TTY" &
```

```console
pi@bot ~ $ sudo nano /etc/pam.d/sshd
```

```
# PAM configuration for the Secure Shell service
# ...
session optional pam_exec.so /home/pi/wks/scripts/notif-login.sh
```
