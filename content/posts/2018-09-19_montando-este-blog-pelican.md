Title: Montando este blog (pelican)
Category: Web
Tags: Pelican, python


**0-** Creo repositorio en github

```console
u@d ~/wks/apuntes $ git clone https://github.com/YOUR_USERNAME/YOUR_USERNAME.github.io.git
...
u@d ~/wks/apuntes $ cd YOUR_USERNAME.github.io
u@d ~/wks/apuntes $ git checkout -b source
u@d ~/wks/apuntes $ echo "output/" >> .gitignore
```

(*) La última linea es porque el directorio `output` no es necesario en la rama `source` si no en la `master`,
así me evito que cuando trabajo con la `source` me moleste con los cambios en los `html`,
cosa muy frecuente porque, por tema de urls relativas o absolutas, cambian cada vez que haces
la versión para desarrollo o para producción.

**1-** Instalar `pelican` y crear blog

```console
u@d ~/wks/apuntes $ sudo pip3 install pelican markdown ghp-import
...
u@d ~/wks/apuntes $ pelican-quickstart
> Where do you want to create your new web site? [.]
> What will be the title of this web site? Apuntes
> Who will be the author of this web site? (mejor aquí que en un txt perdido)
> What will be the default language of this web site? [es]
> Do you want to specify a URL prefix? e.g., http://example.com   (Y/n) n
> Do you want to enable article pagination? (Y/n) y
> How many articles per page do you want? [10] 10
> What is your time zone? [Europe/Madrid]
> Do you want to generate a Fabfile/Makefile to automate generation and publishing? (Y/n) Y
> Do you want an auto-reload & simpleHTTP script to assist with theme and site development? (Y/n) n
> Do you want to upload your website using FTP? (y/N) n
> Do you want to upload your website using SSH? (y/N) n
> Do you want to upload your website using Dropbox? (y/N) n
> Do you want to upload your website using S3? (y/N) n
> Do you want to upload your website using Rackspace Cloud Files? (y/N) n
> Do you want to upload your website using GitHub Pages? (y/N) y
> Is this your personal page (username.github.io)? (y/N) y
Done. Your new project is available at /home/username/YOUR_USERNAME.github.io
```

**2-** Creo la estructura

```console
u@d ~/wks/apuntes $ mkdir -p content/extra content/images content/pages content/posts myplugins j2 themes
```

**3-** Importar wordpress

```console
u@d ~/wks/apuntes $ pelican-import --markup markdown --wpfile -o content ~/Descargas/apuntes.wordpress.2018-09-18.xml
```

Con `sed` y `grep` saco las referencias de las urls a imágenes, las descargo y edito los `.md` para que las usen. (*)

(*) Esto se podría haber hecho directamente con `pelican-import`, ver su ayuda.

**4-** Creo y configuro plugins y tema

* Creo un `reader` (ver [github - reader.py](::SOURCE_URL::/myplugins/reader.py)) para que:
    * se auto generen los tags en base al contenido del `post`
    * ... *próximamente más*
* Creo una extensión `markdown` (ver [github - replacements.py](::SOURCE_URL::/myplugins/replacements.py)) para remplazar palabras claves por variables antes de generar el html
* Creo una extensión `pelican` (ver [github - mod_html.py](::SOURCE_URL::/myplugins/mod_html.py)) para hacer modificaciones en los `html` finales, por ejemplo poner automaticamente `target="_blank"` a todos los enlaces que no sean locales (y no tengan ya definido un target). Seria mucho más eficiente hacerlo con un `plugin` que solo tratara los markdown tras su conversión en `html`, pero no quiero dejarme fuera el contenido de los templates (menú, pie, etc)
* Creo una extensión `pelican` (ver [github - set_count.py](::SOURCE_URL::/myplugins/set_count.py)) para añadir a los objetos `tag` y `category` el número de artículos que contienen
* Creo una extensión `pelican` (ver [github - mod_content.py](::SOURCE_URL::/myplugins/mod_content.py)) para modificar el resultado html de los contenidos. Por ahora sirve para:
    * Cambiar los atributos deprecados `align` por clases que hagan la misma función
    * ... *próximamente más*
* Creo un filtro `jinja2` (ver [github - jinja_filters.py](::SOURCE_URL::/myplugins/jinja_filters.py)) para mostrar las estadísticas de un texto (lineas, palabras, letras)
* Copio el tema `notmyidea` (ver [github - notmyidea-custom](::SOURCE_URL::/themes/notmyidea-custom)) para modificarlo y simplificarlo. También le creo algunos `templates` nuevos como el de los mapas (la versión `xml` para robots y la versión `html` para humanos).
* Modifico `Makefile` para añadir validación html5 y alguna cosa más (ver [github - Makefile](::SOURCE_URL::/Makefile))
* Creo el script `renombrar.py` que cambia los nombres de los `.md` para que se adecuen la formato deseado
* Modifico `pelicanconf.py` para reflejar todo lo anterior  (ver [github - pelicanconf.py](::SOURCE_URL::/pelicanconf.py))

**5-** Actualizo y publico

```console
u@d ~/wks/apuntes $ git add -A && git commit -a -m 'first commit' && git push --all
u@d ~/wks/apuntes $ make github
```

Fuentes:
[nafiulis.me](http://nafiulis.me/making-a-static-blog-with-pelican.html), [fullstackpython.com](https://www.fullstackpython.com/blog/generating-static-websites-pelican-jinja2-markdown.html),
[rsip22.github.io](https://rsip22.github.io/blog/create-a-blog-with-pelican-and-github-pages.html),
[python-markdown.github.io](https://python-markdown.github.io/extensions/api/)
