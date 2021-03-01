Title: Configurar Anbox con mitmdump
Category: Programación
tags: mitm, anbox, mitmdump

**Problema**: Queremos obtener la api de una app

**Solución**: Instalar la app en Anbox y ejecutar un ataque
[man-in-the-middle](https://es.wikipedia.org/wiki/Ataque_de_intermediario)
para inspeccionar las llamadas http que hace la app

Para ello vamos a necesitar:

* [Anbox](https://anbox.io/) para ejecutar la aplicación
* [adb](https://packages.debian.org/sid/android-tools-adb) para interactuar con Anbox
* [mitmdump](https://docs.mitmproxy.org/stable/overview-tools/) de mitmproxy para el ataque
* un script que capture y guarde las peticiones `http` que nos interesen

*1-* Instalación

```console
$ sudo -H pip3 install mitmproxy
$ snap install --devmode --beta anbox
$ sudo apt install android-tools-adb
```

*2-* Renombrar certificado para usar en android

```console
$ ls ~/.mitmproxy
mitmproxy-ca-cert.cer  mitmproxy-ca-cert.pem  mitmproxy-dhparam.pem
mitmproxy-ca-cert.p12  mitmproxy-ca.pem
$ openssl x509 -inform PEM -subject_hash_old -in ~/.mitmproxy/mitmproxy-ca-cert.cer | head -1
c8750f0d
$ cp ~/.mitmproxy/mitmproxy-ca-cert.cer "$HOME/.mitmproxy/$(openssl x509 -inform PEM -subject_hash_old -in ~/.mitmproxy/mitmproxy-ca-cert.cer | head -1).0"
$ ls ~/.mitmproxy
c8750f0d.0             mitmproxy-ca-cert.p12  mitmproxy-ca.pem
mitmproxy-ca-cert.cer  mitmproxy-ca-cert.pem  mitmproxy-dhparam.pem
```

*3-* Instalar certificado en Anbox

```console
$ snap set anbox rootfs-overlay.enable=true
$ snap restart anbox.container-manager
$ sudo snap run --shell anbox.container-manager
$ mkdir -p /var/snap/anbox/common/rootfs-overlay/system/etc/security/cacerts
$ cp /home/TU_USUARIO/.mitmproxy/c8750f0d.0 /var/snap/anbox/common/rootfs-overlay/system/etc/security/cacerts/
$ sudo chown -R 100000:100000 /var/snap/anbox/common/rootfs-overlay
$ exit
$ sudo snap restart anbox.container-manager
```

*4-* Configurar proxy en Anbox

```console
$ adb devices
List of devices attached
emulator-5558	device
$ adb shell settings put global http_proxy 192.168.1.126:8080
```

**Nota**: Cambia `192.168.1.126` por la ip de la máquina donde se ejecutar mitmproxy

*5-* Instalar app en Anbox

```console
$ adb install app.apk
```

*6-* Crear script para capturar tráfico

Por lo general nos van a interesar las peticiones que devuelvan `json`.
El siguiente script (`mitmjson.py`) captura esas peticiones y las guarda en una
estructura de directorios basada en el `hostname` y `path` de la `url`.

**Nota**: Para evitar capturar peticiones indiscriminadamente, este script
solo guarda ficheros `json` en carpetas que ya existan, es decir, debemos
crear manualmente una carpeta por `hostname` que queramos capturar.

```python
import json
import os
import sys
from datetime import datetime
from urllib.parse import urlparse
import yaml

from mitmproxy.net.http import cookies


def get_json(text):
    if text:
        try:
            return json.loads(text)
        except Exception as e:
            pass
    return None


def format_request_cookies(fields):
    return format_cookies(cookies.group_cookies(fields))


def format_response_cookies(fields):
    return format_cookies((c[0], c[1][0], c[1][1]) for c in fields)


def format_cookies(cookie_list):
    rv = []

    for name, value, attrs in cookie_list:
        cookie_har = {
            "name": name,
            "value": value,
        }

        for key in ("path", "domain", "comment"):
            if key in attrs:
                cookie_har[key] = attrs[key]

        rv.append(cookie_har)

    return rv


def name_value(obj):
    r = {}
    for k, v in obj.items():
        r[k] = v
    return r

def response(flow):
    uparse = urlparse(flow.request.url)

    if not uparse.hostname:
        print(flow.request.url)
        return

    js = get_json(flow.response.get_text(strict=False))
    if not js:
        return

    if uparse.hostname not in os.listdir("."):
        print(flow.request.url)
        return

    req_cookies = format_request_cookies(flow.request.cookies.fields)
    res_cookies = format_response_cookies(flow.response.cookies.fields)
    req_content_type = flow.request.headers.get("Content-Type", None)
    res_content_type = flow.response.headers.get("Content-Type", None)
    res_redirect = flow.response.headers.get('Location', None)

    info = {
        "request": {
            "method": flow.request.method,
            "url": flow.request.url,
            "headers": name_value(flow.request.headers),
        },
        "response": {
            "status": flow.response.status_code,
            "statusText": flow.response.reason,
            "headers": name_value(flow.response.headers),
            "json": js
        }
    }

    if len(req_cookies) > 0:
        info["request"]["cookies"] = req_cookies
    if len(res_cookies) > 0:
        info["response"]["cookies"] = res_cookies
    if res_content_type:
        info["response"]["mimeType"] = res_content_type
    if res_redirect:
        info["response"]["redirectURL"] = res_redirect

    if flow.request.method in ("GET", "POST", "PUT", "PATCH"):
        req_params = {}
        for a, b in flow.request.urlencoded_form.items(multi=True):
            req_params[a] = b
        req_text = flow.request.get_text(strict=False)
        req_json = get_json(req_text)
        postData = {}
        if req_content_type:
            postData["mimeType"] = req_content_type
        if len(req_params) > 0:
            postData["params"] = req_params
        if req_json:
            postData["json"] = req_json
        elif req_text:
            postData["text"] = req_text
        info["request"]["postData"] = postData

    name = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
    if uparse.path:
        name = name + uparse.path.replace("/", ".")
    name = uparse.hostname + "/" + name + ".json"
    print(flow.request.url + " ---> " + name)
    with open(name, "w") as f:
        f.write(json.dumps(info, indent=4, sort_keys=True))
```

*7-* Arrancar mitmdump

```
$ mkdir hostname.com
$ mitmdump --flow-detail 0 -s "mitmjson.py" | sed '/:.* \(clientdisconnect\|clientconnect\)/d'
```

**Nota**: Uso `sed` para eliminar de la salida los abundantes reportes
por conexiones y desconexiones.

**Fuentes**:
[jeroenhd.nl](https://blog.jeroenhd.nl/article/android-7-nougat-and-certificate-authorities),
[github - anbox/issues/398](https://github.com/anbox/anbox/issues/398),
[github - anbox/issues/1097](https://github.com/anbox/anbox/issues/1097),
[docs.anbox.io](https://docs.anbox.io/userguide/advanced/rootfs_overlay.html)
