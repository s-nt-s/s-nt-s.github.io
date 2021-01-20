Title: VPN a través de docker
Category: Sistemas
Tags: VPN, VPNC, Docker
body_class: ulcompact
SOURCE: https://github.com/s-nt-s/docker-vpnc/blob/master/README.md
footer: <hr/>\n\nRepositorio con todo el código en [github.com/s-nt-s](https://github.com/s-nt-s/docker-vpnc)

## Objetivo

Necesitamos pasar por una VPN para acceder a algunos servicios, pero para el
resto de nuestras conexiones queremos evitar dicha VPN.

Una posible solución seria usar [IPTABLES con discriminación por usuario](https://www.niftiestsoftware.com/2011/08/28/making-all-network-traffic-for-a-linux-user-use-a-specific-network-interface/)
pero puede resultar demasiado complejo.

Por ello aquí se presenta una alternativa que consiste en crear una imagen
docker con un servidor SSH levantado y con la VPN configurada y activada
de manera que podamos hacer conexiones a través de la imagen solo cuando nos
interese ir a través de la VPN.

Nota: Este desarrollo esta montado sobre VPNC (Cisco VPN) porque es lo que
actualmente tengo que usar en el curro, pero sería fácilmente modificable para usar con OpenVPN
u otra alternativa.

## Piezas

* [`config/default.conf`](https://github.com/s-nt-s/docker-vpnc/raw/master/config/default.example.conf) debe contener la configuración de nuestra VPNC
* [`config/authorized_keys`](https://github.com/s-nt-s/docker-vpnc/raw/master/config/authorized_keys.example) debe incluir la clave pública con la que nos
queremos poder conectar a la máquina docker
* [`config/init.sh`](https://github.com/s-nt-s/docker-vpnc/raw/master/config/init.sh) es el script que arrancara el servidor SSH y conectara la VPNC
al iniciar la imagen docker
* [`Dockerfile`](https://github.com/s-nt-s/docker-vpnc/raw/master/Dockerfile) es la definición de nuestra imagen docker
* [`install.sh`](https://github.com/s-nt-s/docker-vpnc/raw/master/install.sh) es un pequeño script que crea una imagen y configura un servicio
`systemd` para manejarla

## Pasos

### Clave SSH

Para crear la clave ssh podemos hacer:

```
$ ssh-keygen -t rsa -f ~/.ssh/docker-vpnc -C "docker-vpnc"
$ cp ~/.ssh/docker-vpnc.pub config/authorized_keys
```

### Instalar imagen y servicio

Para crear la imagen y arrancarla:

```
$ sudo ./install.sh
$ sudo systemctl daemon-reload
$ sudo systemctl start dvpnc.service
```

### Ejemplo de uso (~/.ssh/config)

Como ejemplo, podemos configurar muestro `~/.ssh/config` de esta manera:

```
Host docker-vpnc
    HostName localhost
    User vpnc
    Port 52022
    IdentityFile ~/.ssh/docker-vpnc

Host in
    HostName 10.2.42.162
    IdentityFile ~/.ssh/in
    User myuser
    ProxyJump docker-vpnc

Host out
    HostName 10.2.42.162
    IdentityFile ~/.ssh/out
    User myuser
```

y cuando queramos entrar a la máquina `10.2.42.162` que es solo accesible a
través de la VPN nos bastara con hacer `ssh in`, mientras que si queremos
entrar en la máquina `10.2.42.162` que esta fuera de la VPN podremos hacer
`ssh out`. Así ambas máquinas serán accesibles a la vez.

Nota: Si se quiere usar un puerto distinto a `52022` hay que editar `./install.sh`
y `~/.ssh/config`

<hr/>

Repositorio con todo el código en [github.com/s-nt-s](https://github.com/s-nt-s/docker-vpnc)