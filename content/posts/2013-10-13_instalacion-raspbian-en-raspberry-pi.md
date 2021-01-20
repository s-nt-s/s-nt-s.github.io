Title: Instalación Raspbian en Raspberry Pi
Date: 2013-10-13 21:08
Category: Sistemas
Tags: Linux, Raspberry Pi
Slug: instalacion-raspbian-en-raspberry-pi


**1-** Obtener la imagen de Raspbian

Vamos a <http://www.raspberrypi.org/downloads> y descargamos la última
versión de yyyy-mm-dd-wheezy-raspbian.zip y la descomprimimos obteniendo
un archivo del mismo nombre pero con extensión .img

**2-** Quemamos la imagen en nuestra tarjeta SD

Para ello podemos instalar el programa ImageWriter

```console
user@bot ~ $ sudo apt-get -y install imagewriter
...
user@bot ~ $ sudo imagewriter
```

![imagen\_writer]({static}/images/imagen_writer.png)

**3-** Arrancar Raspberry Pi con nuestra SD
