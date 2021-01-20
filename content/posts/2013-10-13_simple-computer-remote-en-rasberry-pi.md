Title: Simple Computer Remote en Rasberry Pi
Date: 2013-10-13 22:27
Category: Sistemas
Tags: Linux, Raspberry Pi
Slug: simple-computer-remote-en-rasberry-pi


**1-** Instalar servidor en Rasberry Pi

Obtener de
[http://philproctor.github.io/SimpleComputerRemote](http://philproctor.github.io/SimpleComputerRemote/)
el fichero .deb e instalarlo

```console
pi@rasp ~ $ wget http://philproctor.github.io/SimpleComputerRemote/downloads/simplecomputerremote_1.2_armhf.deb
...
pi@rasp ~ $ sudo dpkg -i simplecomputerremote_1.2_armhf.deb
```

**2-** Hacemos que se arranque con cada inicio de sesión

Generamos el archivo `SimpleComputerRemote.desktop` en
`/home/pi/.config/autostart`

```console
pi@rasp ~ $ mkdir /home/pi/.config/autostart
pi@rasp ~ $ nano /home/pi/.config/autostart/SimpleComputerRemote.desktop
```

con el siguiente contenido

```
[Desktop Entry]
name=SimpleComputerRemote
GenericName=Remote Control
Comment=Allow remote control using Simple Computer Remote
Exec=/opt/rekap/SimpleComputerRemote
Terminal=False
Type=Application
```

Reiniciamos

```console
pi@rasp ~ $ sudo reboot
```

**3-** Instalamos el cliente en nuestro móvil Android

Vamos a <https://play.google.com/store/apps/details?id=com.rekap.remote>
y lo instalamos

**4-** Lo configuramos para que se autoconecte

Conectamos el movil a la misma red en la que esta nuestra Raspberry Pi.
Arrancamos la aplicación en nuestro móvil, pulsamos en "Settings",
marcamos "Auto-Connect" y elegimos en "Select Server" la opción "First"
