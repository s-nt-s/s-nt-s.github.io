Title: Configurar IP fija en Linux
Date: 2013-10-14 16:30
Category: Sistemas
Tags: Linux, Raspberry Pi
Slug: configurar-ip-fija-en-raspbian


**Problema**: Queremos conectarnos remotamente a nuestro equipo sin
tener que consultar antes su IP

**Solución**: Configurar una IP estática para la red LAN, obtener una IP
estática en internet a través de un servicio externo (no-ip) y/o
automatizar una notificación para que se nos avise cada vez que cambie
la IP

**A) IP fija en la red local**

**1-** Definimos la IP que queremos usar:

```console
pi@bot ~ $ sudo nano /etc/network/interfaces
```

`interfaces` ANTES:

```
auto lo

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface default inet dhcp
```

Comentamos la linea 4 para deshabilitar la IP dinámica y añadimos las
lineas de la 6 a la 9 para configurar nuestra IP estática siendo
192.168.1.69 el valor elegido.

`interfaces` DESPUES:

```
auto lo

iface lo inet loopback
#iface eth0 inet dhcp

iface eth0 inet static
 address 192.168.1.69
 netmask 255.255.255.0
 gateway 192.168.1.1

allow-hotplug wlan0
iface wlan0 inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface default inet dhcp
```

**2-** Configuramos el servidor DNS

```console
pi@bot ~ $ sudo nano /etc/resolv.conf
```

Si en él ya aparece un "nameserver" entonces no es necesario editarlo,
en caso contrario hay que añadir un servidor DNS (el 8.8.8.8 de Google,
la del router - "DNS Server Configuration" en <http://192.168.1.1> - o
la de tu ISP) para que quede, por ejemplo, así:

```
domain Home
search Home
nameserver 87.216.1.65
nameserver 87.216.1.66
```

**B) IP fija en internet**

**1-** Registrar una cuenta en [noip.com](http://www.noip.com/)y añadir
un Host a nuestra cuenta.

Menú -&gt; Hosts/Redirects -&gt; Add a Host

![noip]({static}/images/noip1.png)

**2-** Instalar el paquete NO-IP en Raspberry Pi

```console
pi@bot ~ $ wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
...
pi@bot ~ $ tar -zxf noip-duc-linux.tar.gz
pi@bot ~ $ cd noip-2.1.9-1/
pi@bot ~/noip-2.1.9-1 $ make
...
pi@bot ~/noip-2.1.9-1 $ sudo make install
...
Please enter the login/email string for no-ip.com nuestro_usuario_noip
Please enter the password for user 'nuestro_usuario_noip' ******
```

Una vez instalado, si necesitas repetir la configuración del paquete
NO-IP (por ejemplo, porque has añadido nuevos dominios a tu cuenta)
ejecuta:

```console
pi@bot ~ $ sudo /usr/local/bin/noip2 -C
```

**3-** Configurar arranque automático de no-ip

Creamos el archivo noip2 con el contenido detallado más abajo

```console
pi@bot ~ $ sudo touch /etc/init.d/noip2
pi@bot ~ $ sudo chmod +x /etc/init.d/noip2
pi@bot ~ $ sudo nano /etc/init.d/noip2
```

```bash
#! /bin/bash
### BEGIN INIT INFO
# Provides: Servicio No-IP
# Required-Start: $syslog
# Required-Stop: $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: arranque automatico para no-ip
# Description:
#
### END INIT INFO
sudo /usr/local/bin/noip2
```

Le damos permisos de ejecución y lo ponemos en la cola de ejecución y
reiniciamos

```console
pi@bot ~ $ sudo update-rc.d noip2 defaults
pi@bot ~ $ sudo reboot
```

**Nota**: Algunos routers no permiten acceder a la red local desde ellos
mismos pasando por internet ([NAT
Loopback](http://en.wikipedia.org/wiki/Network_address_translation#NAT_loopback)),
es decir, si parece que tu dirección no-ip no funciona prueba a usarla
desde una conexión a internet distinta a la del router al que estas
intentando acceder.

**C) Notificar IP real cada vez que cambie  
**

**1**- Crear comando que nos devuelva nuestra ip

```console
pi@bot ~ $ sudo touch /usr/local/bin/getip
pi@bot ~ $ sudo chmod 777 /usr/local/bin/getip
pi@bot ~ $ sudo nano /usr/local/bin/getip
```

```bash
#!/bin/sh
IP=$(curl -s icanhazip.com)
if [ -z "$IP" ]; then
        IP=$(curl -s ifconfig.me)
fi
if [ -z "$IP" ]; then
        exit 1
fi
echo "$IP"
exit 0
```

**2**- Crear script en /etc/network/if-up.d/

```console
pi@bot ~ $ sudo touch /etc/network/if-up.d/sendip
pi@bot ~ $ sudo chmod +x /etc/network/if-up.d/sendip
pi@bot ~ $ sudo nano /etc/network/if-up.d/sendip
```

```bash
#!/bin/sh
IP=$(getip)
if [ -z "$IP" ]; then
        exit 1
fi
if [ -f /tmp/lastip ]; then
        LAST=$(cat /tmp/lastip)
        if [ "$LAST" = "$IP" ]; then
                exit 0
        fi
fi
echo "$IP" > /tmp/lastip
say "$IP"
exit 0
```

**Nota**: El comando “say” es el implementado en “[Notificaciones xmmp
desde linux](http://apuntes.pusku.com/914)” y podría ser sustituido por
algún otro método de notificación que deseemos, por ejemplo mandarnos un
mail

**BONUS**: Si queremos que nuestro equipo este disponible contra viento
y marea quizá nos interese que sea capaz de [reconectar
automáticamente](http://apuntes.pusku.com/646) en caso de caida.

**Fuentes del punto c:**
[antonio-mario.com](http://antonio-mario.com/tag/if-up-d/),
[www.mathworks.es](http://www.mathworks.es/es/help/simulink/ug/configure-raspberry-pi-hardware-to-email-ip-address-changes.html)
