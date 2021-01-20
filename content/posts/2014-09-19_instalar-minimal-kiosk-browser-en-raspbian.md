Title: Instalar Minimal Kiosk Browser en Raspbian
Date: 2014-09-19 13:16
Category: Utilidades
Tags: Raspberry Pi
Slug: instalar-minimal-kiosk-browser-en-raspbian


**Problema**: Queremos ver webs y alguna cosilla más desde nuestra
Raspbery pero no queremos arrancar un entorno de escritorio completo

**Solución**: Instalar Minimal Kiosk Browser

```console
pi@bot ~ $ cd /tmp
pi@bot /tmp wget http://steinerdatenbank.de/software/kweb-1.5.4.1.tar.gz
...
pi@bot /tmp tar -xzf kweb-1.5.4.1.tar.gz
pi@bot /tmp/kweb-1.5.4.1 ./prepare
Nos dirá que paquetes nos falta
pi@bot /tmp/kweb-1.5.4.1 sudo apt-get install paquetes que nos faltan
...
pi@bot /tmp/kweb-1.5.4.1 sudo ./install
```

Para ejecutar sin tener que arrancar el entorno de escritorio:

```console
pi@bot ~ $ xinit ./ktop
```

O para facilitar su uso podemos [crear un
alias](http://felinfo.blogspot.com.es/2011/12/creacion-y-uso-de-alias-de-comandos.html)

`~/.bashrc`

```
alias ktop="xinit ~/ktop"
```

Documentación: [kweb
manual](http://steinerdatenbank.de/software/kweb_manual.pdf),
[omxplayerGUI
manual](http://steinerdatenbank.de/software/omxplayerGUI_manual.pdf),
[changelog](http://steinerdatenbank.de/software/kweb_changelog.html)

Fuente:
[www.raspberrypi.org](http://www.raspberrypi.org/forums/viewtopic.php?t=40860)
