Title: Añadir resolución con xrandr
Date: 2013-10-03 17:14
Category: Escritorio
Tags: Linux, xrandr
Slug: anadir-resolucion-con-xrandr

Usando el terminal de linux:

1.  Ver las resoluciones disponibles que hay (xrandr)
2.  Obtener los valores (modeline) de la resolución que queremos
    añadir (cvt)
3.  Añadir con la resolución que queremos al listado de disponibles
4.  Asignar la resolución al monitor deseado
5.  Poner el monitor en dicha resolución

Ejemplo: Añadir la resolución 1368x768 al monitor VGA1

```console
user@bot ~ $ xrandr
Screen 0: minimum 320 x 200, current 2390 x 768, maximum 32767 x 32767
LVDS1 connected 1366x768+0+0 (normal left inverted right x axis y axis) 256mm x 144mm
   1366x768       60.1*+
   1360x768       59.8     60.0
   1024x768       60.0
   800x600        60.3     56.2
   640x480        59.9
VGA1 connected 1024x768+1366+0 (normal left inverted right x axis y axis) 0mm x 0mm
   1024x768       60.0*
   800x600        60.3     56.2
   848x480        60.0
   640x480        59.9
user@bot ~ $ cvt 1366 768
# 1368x768 59.88 Hz (CVT) hsync: 47.79 kHz; pclk: 85.25 MHz
Modeline "1368x768_60.00"   85.25  1368 1440 1576 1784  768 771 781 798 -hsync +vsync
user@bot ~ $ xrandr --newmode 1368x768 85.25  1368 1440 1576 1784  768 771 781 798 -hsync +vsync
user@bot ~ $ xrandr --addmode VGA1 1368x768
user@bot ~ $ xrandr --output VGA1 --mode 1368x768
user@bot ~ $ xrandr
Screen 0: minimum 320 x 200, current 2390 x 768, maximum 32767 x 32767
LVDS1 connected 1366x768+0+0 (normal left inverted right x axis y axis) 256mm x 144mm
   1366x768       60.1*+
   1360x768       59.8     60.0
   1024x768       60.0
   800x600        60.3     56.2
   640x480        59.9
VGA1 connected 1368x768+0+0 (normal left inverted right x axis y axis) 0mm x 0mm
   1024x768       60.0
   800x600        60.3     56.2
   848x480        60.0
   640x480        59.9
   1368x768       59.9*
```

**Bonus**: Hacer que el comando se repita cada vez que inicia el sistema
para que no haya que hacerlo a mano cada vez

```console
user@bot ~ $ sudo gedit /etc/mdm/Init/Default
```

Agregamos las nuevas lineas debajo de donde se define el path

```bash
...
PATH=/usr/bin:$PATH
OLD_IFS=$IFS

xrandr --newmode 1368x768 85.25  1368 1440 1576 1784  768 771 781 798 -hsync +vsync
xrandr --addmode VGA1 1368x768
xrandr --output VGA1 --mode 1368x768

mdmwhich () {...
```
