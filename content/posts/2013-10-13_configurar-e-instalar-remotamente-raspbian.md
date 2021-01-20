Title: Configurar e instalar remotamente Raspbian
Date: 2013-10-13 21:25
Category: Sistemas
Tags: Linux, Raspberry Pi
Slug: configurar-e-instalar-remotamente-raspbian


**Problema**: Queremos instalar Raspbian en Raspbarry Pi pero no tenemos
teclado usb que enchufarle

**Solución**: Automatizar la instalación y configurar remotamente
nuestra Raspberry

**1-** Instalamos Raspbian en nuestra targeta SD

Hay dos opciones:

* [Automatizar la instalación vía NOOBS]({filename}./2013-10-13_instalacion-desatendida-con-noobs-en-raspberry-pi.md)
* [Quemar una imagen con el sistema instalado]({filename}./2013-10-13_instalacion-raspbian-en-raspberry-pi.md)

**2-** Arrancamos la Raspberry Pi con la tarjeta SD

**3-** Averiguamos la IP de la Raspberry Pi

Entramos en la configuración de nuestro router (<http://192.168.1.1/>) y
vamos al apartado Device Info -- DHCP Leases (según el modelo del router
esto puede cambiar)

![captura-DHCP-router]({static}/images/DHCP-router.png)

**4-** Conectamos vía ssh

Conectamos con el usuario "pi" a la ip obtenida en el paso anterior,
responemos "yes" a la pregunta que nos hacen y tecleamos "raspberry"
como contraseña. Finalmente actualizamos como se nos indica el software

```console
user@bot ~ $ ssh pi@192.168.1.132
The authenticity of host '192.168.1.132 (192.168.1.132)' can't be established.
ECDSA key fingerprint is e8:c5:6d:df:58:a7:a3:5a:7d:e6:f2:9d:dd:43:b1:d0.
Are you sure you want to continue connecting (yes/no)? <strong>yes</strong>
Warning: Permanently added '192.168.1.132' (ECDSA) to the list of known hosts.
pi@192.168.1.132's password: <strong>raspberry</strong>
```

**5-** Configuramos las opciones de Raspbian

Nos metemos en el panel de configuración

```console
pi@raspberrypi ~ $ sudo raspi-config
```

![confgpi]({static}/images/confgpi.png)

Ejecutamos como mínimo:

* Expand Filesystem
* Advance options -&gt; SSH -&gt; Enabled
* Advance option -&gt; Update

Además si queremos que al arrancar se inicie el entrono gráfico
ejecutaremos "Enable Boot to Desktop/Scratch -&gt; Desktop Log in as
user 'pi' at the graphical desktop"

Le damos a finalizar y cuando nos pregunte si queremos reiniciar le
decimos que si.

**6-** Actualizar software

```console
pi@raspberry ~ $ sudo apt-get update
...
pi@raspberry ~ $ sudo apt-get upgrade
```

**7-** Manejar entorno gráfico remotamente

Dos opciones:

* [Desde el móvil con Simple Computer
    Remote]({filename}./2013-10-13_simple-computer-remote-en-rasberry-pi.md)
* Desde un cliente VNC

------------------------------------------------------------------------

Fuentes:

-   [sobrebits.com](http://sobrebits.com/montar-un-servidor-casero-con-raspberry-pi-parte-2-primera-ejecucion-de-raspbian/)
-   [deeiivid.wordpress.com](http://deeiivid.wordpress.com/2013/02/23/guia-completa-raspberry-pi-espanol/)
