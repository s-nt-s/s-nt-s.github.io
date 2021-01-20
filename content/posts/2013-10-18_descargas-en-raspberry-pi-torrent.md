Title: Descargas en Raspberry Pi
Date: 2013-10-18 18:21
Category: Sistemas
Tags: Linux, pyLoad, Raspberry Pi, Transmission
Slug: descargas-en-raspberry-pi-torrent


**1-** Crear carpetas donde se almacenaran las descargas

```console
pi@bot ~ $ cd /
pi@bot / $ sudo mkdir dwn
pi@bot / $ cd dwn
pi@bot /dwn $ sudo mkdir cmp
pi@bot /dwn $ sudo mkdir tmp
pi@bot /dwn $ sudo chmod 777 cmp
pi@bot /dwn $ sudo chmod 777 tmp
```

**2-** Instalar transmission (para torrents)

Nada más instalarlo pararemos el servicio (daemon) que nos crea.

```console
pi@bot ~ $ sudo apt-get -y install transmission-daemon
...
[ ok ] Starting bittorrent daemon: trasnsmision-daemon.
...
pi@bot ~ $ sudo /etc/init.d/transmission-daemon stop
[ ok ] Stopping bittorrent daemon: trasnsmision-daemon.
```

**3-** Configurar transmission

```console
pi@bot ~ $ sudo nano /var/lib/transmission-daemon/info/settings.json
```

```json
{
...
"download-dir": "/dwn/cmp",
"incomplete-dir-enabled": true,
"incomplete-dir": "/dwn/tmp",
"rpc-enabled": true,
"rpc-bind-address": "0.0.0.0",
"rpc-username": "descargas",
"rpc-password": "12345",
"rpc-whitelist-enabled": false,
...
}
```

Con esto hacemos que las descargas se almacenen en /dwn/tmp hasta que
están completas y entonces pasan a /dwn/cmp, y también hacemos que
podamos gestionar las descargas a traves de http://nuestra-ip:9091
validándonos con el usuario 'descargas' y contraseña '12345'

**4-** Arrancamos transmission

```console
pi@bot ~ $ sudo /etc/init.d/transmission-daemon start
[ ok ] Starting bittorrent daemon: trasnsmision-daemon.
```

**Bonus**: [Notificaciones](http://apuntes.pusku.com/914) cuando se
finaliza una descarga

**5-** Instalar pyLoad (para descargas directas)

```console
pi@bot ~ $ sudo aptitude install liblept3
...
pi@bot ~ $ sudo aptitude install python python-crypto python-pycurl python-imaging python-openssl tesseract-ocr python-qt4 spidermonkey-bin zip unzip unrar-free
...
pi@bot ~ $ wget http://download.pyload.org/pyload-v0.4.9-all.deb
...
pi@bot ~ $ sudo dpkg -i pyload-v0.4.9-all.deb
```

**6-** Configurar pyLoad

```console
pi@bot ~ $ pyLoadCore -s
...
## Revisión del sistema ##
Versión de Python: OK
pycurl: OK
sqlite3: OK
pycrypto: OK
py-OpenSSL: OK
py-imaging: OK
tesseract: OK
PyQt4: OK
jinja2: OK
beaker: OK
Motor JS: OK
...
```

Si no da todo OK revisar que todos los paquetes del paso 5 se han
instalado y/o intentar instalarlos individualmente.

```console
...
¿Realizar el ajuste básico? ([s]/n): s
...
Nombre de usuario [User]: descargas
Contraseña:  12345
...
Activar acceso remoto ([s]/n): s
Idioma ([en], de, fr, it, es, nl, sv, ru, pl, cs, sr, pt_BR): es
Directorio de descargas [Downloads]: /dwn/cmp
...
¿Configurar la interfaz web? ([s]/n): s
¿Activar interfaz web? ([s]/n): s
Dirección de escucha, si usas 127.0.0.1 o localhost, la interfaz web solo podrá ser accesible localmente.
Dirección [0.0.0.0]: 0.0.0.0
Puerto [8000]: 8000
```

**7-** Crear arranque automático

```console
pi@bot ~ $ crontab -e
```

Añadir la siguiente linea

```
@reboot pyLoadCore --daemon
```

 Fuente:
[electroensaimada.com](http://www.electroensaimada.com/torrent.html),
[foro.androidpc.es](http://foro.androidpc.es/showthread.php?tid=1009),
[jankarres.de](http://jankarres.de/2013/06/raspberry-pi-how-to-install-pyload-downloadmanager/)
y
[megaleecher.net](http://www.megaleecher.net/Free_download_manager_for_Raspberry_Pi)
