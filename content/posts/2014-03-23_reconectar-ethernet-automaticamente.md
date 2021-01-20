Title: Reconectar ethernet automaticamente
Date: 2014-03-23 20:35
Category: Sistemas
Tags: Linux
Slug: reconectar-ethernet-automaticamente


**Problema**: Un equipo conectado vía ethernet se desconecta sin motivo
aparente. Este equipo se usa siempre remotamente, por lo tanto acceder
físicamente a él para reiniciarlo no es una buena solución.

**Solución**: Automatizar el proceso de monitorizar el estado de la
conexión del ethernet y levantarlo en caso de caída.

**1-** Crear script para ver el estado del ethernet y levantarlo si es
necesario.

```console
pi@bot ~ $ sudo touch /usr/local/bin/eth
pi@bot ~ $ sudo chmod 777 /usr/local/bin/eth
pi@bot ~ $ sudo nano /usr/local/bin/eth
```

```bash
#!/bin/bash
ok() {
    STATE=$(ifconfig eth0 | grep "inet addr:" | sed 's/^ *inet addr/Lan/' | sed 's/  / /g')
    IP=$(curl -s icanhazip.com)
    if [ ! -z "$IP" ]; then
        echo -n "Ip:$IP "
    else
        echo -n "IP ERROR - "
    fi
    echo "$STATE"
}

if [ "$1" == "--log" ]; then
    echo -n $(date "+%d/%m/%Y %H:%M > ")""
fi

if ifconfig eth0 | grep -q "inet addr:"; then
    ok
    exit 0
fi

ERR=$(ifup --force eth0 2>&1)
OUT=$?
if [ $OUT -eq 0 ] ; then
    echo -n "RESET OK - "
    ok
else
    echo "RESET FAIL - $ERR"
fi
```

**2-** Ejemplo de uso desde linea de comandos

```console
pi@bot ~ $ eth
Ip:81.65.17.125 Lan:192.168.1.69 Bcast:192.168.1.255 Mask:255.255.255.0
pi@bot ~ $ eth --log
23/03/2014 21:14 > Ip:81.65.17.125 Lan:192.168.1.69 Bcast:192.168.1.255 Mask:255.255.255.0
pi@bot ~ $ sudo ifdown eth0
...
pi@bot ~ $ eth
RESET FAIL - ifup: failed to open statefile /run/network/ifstate: Permission denied
pi@bot ~ $ sudo eth
RESET OK - Ip:81.65.17.125 Lan:192.168.1.69 Bcast:192.168.1.255 Mask:255.255.255.0
```

**3-** Programar tarea cada 5 minutos

Editar el crontab de usuario root y añadir las siguientes lineas al
final del fichero

```console
pi@bot ~ $ sudo nano /etc/crontab
```

```
# Cada 5 minutos testeamos el ethernet
*/5 *   * * *   root    /bin/bash /usr/local/bin/eth --log  | grep "RESET\|ERROR" >> /var/log/eth.log
```

**4-** Ejemplos de log generado por crontab

```
20/03/2014 07:05 > RESET OK - Ip:81.65.17.125 Lan:192.168.1.69 Bcast:192.168.1.255 Mask:255.255.255.0
20/03/2014 16:05 > RESET OK - Ip:81.65.17.125 Lan:192.168.1.69 Bcast:192.168.1.255 Mask:255.255.255.0
21/03/2014 17:05 > RESET OK - Ip:81.65.17.125 Lan:192.168.1.69 Bcast:192.168.1.255 Mask:255.255.255.0
```

Fuente:
[samhobbs](http://www.samhobbs.co.uk/2013/11/fix-for-ethernet-connection-drop-on-raspberry-pi/)
([cache](http://webcache.googleusercontent.com/search?q=cache:T9cgkUiSUZsJ:www.samhobbs.co.uk/2013/11/fix-for-ethernet-connection-drop-on-raspberry-pi/+&cd=1&hl=es&ct=clnk))
