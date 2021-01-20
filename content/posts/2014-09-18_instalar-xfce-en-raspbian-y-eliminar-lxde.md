Title: Instalar XFCE en Raspbian y eliminar LXDE
Date: 2014-09-18 14:27
Category: Escritorio
Tags: Raspberry Pi
Slug: instalar-xfce-en-raspbian-y-eliminar-lxde


**1-** Instalar XFCE

```console
pi@bot ~ $ sudo apt-get install xfce4
```

**2-** Eliminar LXDE

Primero listamos los paquetes de LXDE, luego desinstalamos todos los
resultados y finalmente desintalamos los paquetes que han quedado
huérfanos

```console
pi@bot ~ $ sudo dpkg --get-selections | grep "^lx"
lxappearance                                    install
lxde                                            install
lxde-common                                     install
lxde-core                                       install
lxde-icon-theme                                 install
lxinput                                         install
lxmenu-data                                     install
lxmusic                                         install
lxpanel                                         install
lxpolkit                                        install
lxrandr                                         install
lxsession                                       install
lxsession-edit                                  install
lxshortcut                                      install
lxtask                                          install
lxterminal                                      install
pi@bot ~ $ sudo apt-get remove lxappearance lxde lxde-* lxinput lxmenu-data lxmusic lxpanel lxpolkit lxrandr lxsession* lxsession lxshortcut lxtask lxterminal
...
pi@bot ~ $ sudo apt-get autoremove && sudo apt-get autoclean
```

**4-** Instalar paquetes extra para el audio

```console
pi@bot ~ $ sudo apt-get install alsa-base alsa-utils gstreamer0.10-alsa gstreamer0.10-plugins-base xfce4-mixer
...
pi@bot ~ $ sudo apt-get install gstreamer0.10-plugins-good gstreamer0.10-plugins-bad gstreamer0.10-ffmpeg
```

**5-** Reiniciar y arrancar XFCE

```console
pi@bot ~ $ sudo reboot
...
pi@bot ~ $ startx
```

El primer arranque puede tardar varios minutos pero es normal, luego
arrancara mucho más rápido.

Fuentes:
[www.etcwiki.org](http://www.etcwiki.org/wiki/XFCE_desktop_on_raspberry_pi),
raspberrypi.stackexchange.com
\[[1](http://raspberrypi.stackexchange.com/questions/10053/changing-to-xfce-from-lxde)\]
\[[2](http://raspberrypi.stackexchange.com/questions/4745/how-to-uninstall-x-server-and-desktop-manager-when-running-as-headless-server)\],
[mike632t.wordpress.com](http://mike632t.wordpress.com/2014/02/04/installing-xfce/)
