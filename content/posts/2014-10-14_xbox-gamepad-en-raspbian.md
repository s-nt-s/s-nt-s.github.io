Title: Usar gamepad Xbox en Raspbian
Date: 2014-10-14 20:00
Category: Sistemas
Tags: Xbox, gamepad

1- Instalar los dirvers

```console
pi@bot ~ $ sudo apt-get install xboxdrv
```

2- Conectar el receptor wireless

3- Comprobar que se ha detectado

```console
pi@bot ~ $ dmesg | grep Xbox
[ 5217.724011] usb 1-1.2: Product: Xbox 360 Wireless Receiver for Windows
[ 5218.106219] input: Xbox 360 Wireless Receiver as /devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2:1.0/input/input2
[ 5218.118192] input: Xbox 360 Wireless Receiver as /devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2:1.2/input/input3
[ 5218.121125] input: Xbox 360 Wireless Receiver as /devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2:1.4/input/input4
[ 5218.131507] input: Xbox 360 Wireless Receiver as /devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2:1.6/input/input5
```

4- Conectar gamepad

```console
pi@bo ~ $ sudo xboxdrv --trigger-as-button --wid 0 --led 2 --deadzone 4000
xboxdrv 0.8.4 - http://pingus.seul.org/~grumbel/xboxdrv/ 
Copyright © 2008-2011 Ingo Ruhnke <grumbel@gmx.de> 
Licensed under GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> 
This program comes with ABSOLUTELY NO WARRANTY. 
This is free software, and you are welcome to redistribute it under certain conditions; see the file COPYING for details. 

Controller:        Microsoft Xbox 360 Wireless Controller (PC)
Vendor/Product:    045e:0719
USB Path:          001:010
Wireless Port:     0
Controller Type:   Xbox360 (wireless)

Your Xbox/Xbox360 controller should now be available as:
  /dev/input/js1
  /dev/input/event2

Press Ctrl-c to quit, use '--silent' to suppress the event output
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:1 B:0 X:0 Y:0  LB:0 RB:0  LT:  0 RT:  0
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:0 B:0 X:0 Y:0  LB:0 RB:0  LT:  0 RT:  0
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:0 B:0 X:1 Y:0  LB:0 RB:0  LT:  0 RT:  0
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:0 B:0 X:0 Y:0  LB:0 RB:0  LT:  0 RT:  0
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:0 B:0 X:0 Y:1  LB:0 RB:0  LT:  0 RT:  0
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:0 B:0 X:0 Y:0  LB:0 RB:0  LT:  0 RT:  0
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:0 B:1 X:0 Y:0  LB:0 RB:0  LT:  0 RT:  0
X1: -5440 Y1:  2337  X2:  1148 Y2:  1617  du:0 dd:0 dl:0 dr:0  back:0 guide:0 start:0  TL:0 TR:0  A:0 B:0 X:0 Y:0  LB:0 RB:0  LT:  0 RT:  0
```

Nota: Las lineas que empieza por X1 son producidas por loe eventos
lanzado al pulsar los botones del gamepad

Si al ejecutar el primer comando falla, ejecutar *sudo rmmod xpad* y
volver a probar.
