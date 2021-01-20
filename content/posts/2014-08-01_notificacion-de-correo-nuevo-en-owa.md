Title: Notificación de correo nuevo en OWA
Date: 2014-08-01 15:57
Category: Sistemas
Slug: notificacion-de-correo-nuevo-en-owa


**Problema**: Estamos en la situación ya detallada en el anterior post
"[Acceder a OWA a través de otra cuenta de
correo](http://apuntes.pusku.com/251)" pero no nos vale la solución
porque han deshabilitado desde el servidor el acceso EWS

**Solución**: Para reducir las veces que nos vemos obligados a entrar a
OWA construiremos un script que nos avise de cuando hay un correo nuevo

**1-** Crear el script que visitara OWA por nosotros

```console
pi@bot ~ $ cd ~/.owa
pi@bot ~ $ touch inbox.txt
pi@bot ~ $ touch notif.awk
pi@bot ~ $ touch notif.sh
pi@bot ~ $ chmod +x notif.sh
pi@bot ~ $ nano notif.sh
pi@bot ~ $ nano notif.awk
```

`~/.owa/notif.sh`:

```bash
#!/bin/bash

usr1=origen@outloock.com
pas1=passorigen
url=https://mail.ejemplo.com

out=$(lynx -auth=$usr1:$pas1 $url -dump -crawl)

if echo "$out" | grep -q "THE_TITLE:Error"; then
    echo "$out"
    exit 1
fi

CWD=$(dirname $0)

if [ "$1" == "--show" ]; then
    echo "$out" | awk -f $CWD/notif.awk
    exit
fi

echo "$out" | awk -f $CWD/notif.awk | while read ln; do
    if grep -q "$ln" $CWD/inbox.txt; then
        continue
    fi
    echo "$ln" >> $CWD/inbox.txt
    sudo say "$ln"
done
```

**Nota**: El comando `say` es el implementado en "[Notificaciones xmmp
desde linux](http://apuntes.pusku.com/914)" y podría ser sustituido por
algún otro método de notificación que deseemos

`"~/.owa/notif.awk`:

```awk
BEGIN {
        m=0;
        a=0;
        s=0;
}

function ath(s) {
        i=index(s,"[_]");
        s=substr(s,i+3,length(s));
        sub(/^ +/, "", s);
        sub(/ +$/, "", s);
        return s;
}

/\[msg-rd\.png\]/ {
        m=1;
        a=ath($0);
}

/\[msg-unrd\.png\]/ {
        m=2;
        a=ath($0);
}

/\[msg-rpl\.gif\]/ {
        m=3;
        a=ath($0);
}

/^[A-Z]/ {
        if (m!=0) s=$0;
}

$1~/[0-9]+\/[0-9]+\/20[0-9]+/ {
        if (m!=0) {
                print $1, (length($2)==4? ("0" $2) : $2), a , "->" , s;
                m=0;
                a=0;
                s=0;
        }
}
```

**2-** Crear tarea programada

Repetimos el paso homologo del post "[Acceder a OWA a través de otra
cuenta de correo](http://apuntes.pusku.com/251)" pero con el script
`~/.owa/notif.sh`
