Title: Mover procesos entre terminales y planos
Date: 2014-10-03 16:14
Category: Sistemas
Slug: mover-procesos-entre-terminales-y-planos
tags: procesos


**Problema**: Tenemos que ejecutar un proceso desde un terminal que va a
dejar de estar disponible y no queremos que se cancele al cerrar dicho
terminal

**Solución**:  Depende de si ya hemos arrancado el proceso o no.

**A) Procesos sin arrancar**

```console
pi@bot ~ $ nohup ./script.sh &
pi@bot ~ $ exit
```

Esto arrancara script.sh sin que sea asociado a nuestro terminal, y
generar un fichero nohup.out donde se guardara la salida del script.

**B) Procesos ya arrancados**

Si el proceso nos tiene ocupado el terminal tecleamos Control+Z para
dormirlo

```console
pi@bot ~ $ ./script.sh
....
^Z
[1]+ Stopped
pi@bot ~ $ jobs
[1]+ Stopped ./script.sh
pi@bot ~ $ bg 1
[1]+ ./script.sh &
pi@bot ~ $ disown -h %1
pi@bot ~ $ exit
```

Como de esta manera no tenemos disponible ningún nohup.out desde el que
ver la salida la podemos consultar de la siguiente manera:

```console
pi@bot ~ $ ps -e | grep script.sh
12194 ? 04:11:47 script.sh
pi@bot ~ $ tail -f /proc/12194/fd/1
...
```

**C) Recuperar proceso en otro terminal**

```console
pi@bot ~ $ ps -e | grep script.sh
12194 ? 04:11:47 script.sh
pi@bot ~ $ reptyr -s 12194
...
```

Fuente:
[askubuntu.com](http://askubuntu.com/questions/10547/how-to-clean-launch-a-gui-app-via-the-terminal-so-it-doesnt-wait-for-terminati),
[raspi.tv](http://raspi.tv/2012/using-screen-with-raspberry-pi-to-avoid-leaving-ssh-sessions-open),
[monkeypatch.me](http://monkeypatch.me/blog/move-a-running-process-to-a-new-screen-shell.html),
[askubuntu.com](http://askubuntu.com/questions/192798/reading-the-output-from-any-process-using-its-pid)
