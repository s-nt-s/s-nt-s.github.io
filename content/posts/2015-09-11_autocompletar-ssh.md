Title: Autocompletar ssh
Date: 2015-09-11 19:16
Category: Sistemas
Tags: Linux, Ssh
Slug: autocompletar-ssh


**1-** Configurar ~/.ssh/config (ver
[rafael.bonifaz.ec](http://rafael.bonifaz.ec/blog/2011/01/sshconfig-simplifica-nuestra-vida-con-ssh/))

```
Host unhost
HostName un.host.ej
User usuario1
Port 22

Host otrohost
HostName otro.host.ej
User usuario2
Port 22
```

**3-** Instalamos bash-completion (ver
[howtoforge.com](https://www.howtoforge.com/how-to-add-bash-completion-in-debian))

```console
pi@bot ~ $ sudo apt-get install bash-completion
```

**2-** Creamos función de autocompletado en /etc/bash_completion.d/ssh
(ver
[eli.thegreenplace.net](http://eli.thegreenplace.net/2013/12/26/adding-bash-completion-for-your-own-tools-an-example-for-pss)
y
[www.dicas-l.com.br](http://www.dicas-l.com.br/arquivo/configurando_auto-completar_para_favoritos_ssh.php))

```bash
_compssh () {
        if [ -f "${HOME}/.ssh/config" ]; then
                cur=${COMP_WORDS[COMP_CWORD]};
                COMPREPLY=($(compgen -W '$(grep "^Host\b" ${HOME}/.ssh/config | sed -e "s/Host //")' -- $cur))
        fi
}
complete -F _compssh ssh
```

**3-** Reiniciamos o recargamos el fichero (source
/usr/share/bash-completion/bash_completion)

**4-** Probamos

```console
pi@bot ~ $ ssh un + TAB
pi@bot ~ $ ssh unhost
pi@bot ~ $ ssh o + TAB
pi@bot ~ $ ssh otrohost
```
