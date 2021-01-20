Title: Acceder a OWA a través de otra cuenta de correo
Date: 2013-12-17 15:01
Category: Utilidades
Slug: acceder-a-owa-a-traves-de-otra-cuenta-de-correo


**Problema**: Nos vemos obligados a utilizar una cuenta que permite
únicamente acceso por OWA (outlook web access) cuyos servidores tienen
deshabilitado el acceso POP y además tampoco funcionan las reglas de
reenvió

**Solución 1º**: Usar
[davmail](http://davmail.sourceforge.net/serversetup.html) para crear un
acceso pop o imap

**Problema de la solucón 1º**:  La cuenta que va a leer desde ese acceso
pop nos va a pedir que usemos un certificado SSL no auto firmado y ni
queremos pagarlo ni queremos dar acceso a nuestra cuenta sin encriptar

**Solución**:
[davmail](http://davmail.sourceforge.net/serversetup.html) +
[pop2imap](http://www.linux-france.org/prj/pop2imap/) + cuenta
intermedia + nuestra cuenta final

**1-** Crear directorio para el script e instalar las herramientas
necesarias

```console
pi@bot ~ $ mkdir .owa
pi@bot ~ $ cd .owa
pi@bot ~/.owa $ wget http://downloads.sourceforge.net/project/davmail/davmail/4.4.0/davmail-4.4.0-2198.zip
pi@bot ~/.owa $ unzip davmail-*.zip
pi@bot ~/.owa $ rm davmail-*.zip
pi@bot ~/.owa $ aptitude install libmail-pop3client-perl libmail-imapclient-perl libdigest-hmac-perl libemail-simple-perl libdate-manip-perl
pi@bot ~/.owa $ wget http://www.linux-france.org/prj/pop2imap/dist/pop2imap-1.21.tgz
pi@bot ~/.owa $ tar -xzvf pop2imap-*.tgz
pi@bot ~/.owa $ cd pop2imap*
pi@bot ~/.owa/pop2imap-1.21 $ make install
pi@bot ~/.owa/pop2imap-1.21 $ cd ..
pi@bot ~/.owa $ rm -R pop2imap*
pi@bot ~/.owa $ touch owa.sh
pi@bot ~/.owa $ chmod +x owa.sh
```

**2-** Configurar DavMail

`davmail.properties`:

```properties
...
# Modo servidor
davmail.server=true
# Exchange OWA o EWS url
davmail.url=https://mail.ejemplo.com
# Puerto para el acceso POP
davmail.popPort=1110
# El resto de servicios no nos interesan
davmail.caldavPort=
davmail.imapPort=
davmail.ldapPort=
davmail.smtpPort=
# No permitir acceso remoto (solo lo vamos a usar en local)
davmail.allowRemote=false
# Lo dejamos vacio para que escriba el log en la misma carpeta del script
davmail.logFilePath=
...
```

**3-** Crear script de ejecución

`owa.sh`:

```bash
#!/bin/bash

#Editar con nuestros datos
usr1=origen@outloock.com
pas1=passorigen
imp=imap.gmail.com
prt=993
usr2=destino.intermedio@gmail.com
pas2=passdestino
#Crear previmanete una etiqueta en nuestra cuenta destino con este nombre
fld=owa

log() {
    echo "$1"
    echo "$1" >> owa.log
}

pi2=$(ps -ef | grep pop2imap | sed '/ grep /d' | awk '{print $2}')
pid=$(ps -ef | grep davmail  | sed '/ grep /d' | awk '{print $2}')

START_TIME=$SECONDS

cd ~/.owa

dat=$(date "+%d/%m/%Y %H:%M:%S")
log "==== $dat ===="

if [ "$pid" != "" ]; then
    if [ "$pi2" != "" ]; then
            log "OWA ya esta corriendo (davmail=$pid y pop2imap=$pi2)"
            exit 1
    else 
        log "Davmail ya esta corriendo con pid=$pid"
    fi
else
        if [ "$pi2" != "" ]; then
                log "Detenemos pop2imap colgado ($pi2)"
        kill "$pi2"
        fi
    ./davmail.sh davmail.properties > /dev/null &
    pid=$!
    log "Davmail iniciado con pid=$pid"
    sleep 2
fi

log "Iniciando pop2imap"
pop2imap --host1 localhost --port1 1110 --user1 $usr1 --password1 $pas1 --host2 $imp --port2 $prt --user2 $usr2 --password2 $pas2 --folder $fld --ssl2 > pop2imap.log
log "pop2imap parado (pid=$!)"

kill "$pid"
log "Davmail parado"

int=$(($SECONDS - $START_TIME))
mig=$(grep "No Message-ID Need Transfer" pop2imap.log | wc -l)
msg="$mig mails subidos en $int segundos"

log "$msg"

if [ $mig -gt 0 ]; then
    echo "$dat - $msg" >> summary.log
fi
```

**4-** Crear tarea programada

```console
pi@bot ~ $ crontab -e
```

Añadir las siguientes lineas para que el script se ejecute
periódicamente

```
# Cada hora en horario laboral
0 7-20 * * 1,2,3,4  /bin/bash ~/.owa/owa.sh
0 7-18 * * 5  /bin/bash ~/.owa/owa.sh
# Cada 4 horas fuera de horario laboral y entre semana
0 23,3 * * 1,2,3,4  /bin/bash ~/.owa/owa.sh
# Cada 8 horas en fin de semana
0 */8 * 6,7 /bin/bash ~/.owa/owa.sh
```

**5-** Configurar nuestra cuenta final

Ahora nuestra cuenta final puede leer vía pop de la cuenta intermedia
(que funciona como espejo del owa) sin problemas.

------------------------------------------------------------------------

**Notas**: Se podría usar la salida imap que da davmail para [migrar de
imap a imap](http://imapsync.lamiral.info/) pero según la documentación
de davmail su acceso pop es más eficiente. También se podría pensar en
prescindir de la cuenta intermedia y cargarlo todo en la cuenta final
pero entonces no se ejecutarían nuestros filtros sobre este correo
entrante y además si borrásemos un mail este volvería a aparecer en la
próxima sincronización.
