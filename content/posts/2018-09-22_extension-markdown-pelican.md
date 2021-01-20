Title: Crear extensión markdown para usar en pelican
Category: Web
Tags: Pelican, markdown


Según la documentación de `pelican` la manera de incluir un plugin `markdown`
es poniendo en `pelicanconf.py` lo siguiente:

```python
MARKDOWN = {
    'extensions': [ <<aquí van las extensiones>> ],
    'extension_configs': {
        'markdown.extensions.codehilite': {'css_class': 'highlight'},
        'markdown.extensions.extra': {},
        'markdown.extensions.meta': {},
    },
    'output_format': 'html5',
}

```

donde la parte relevante es el array `extensions` ya que lo demás solo se pone
para preservar el valor por defecto de la variable `MARKDOWN`

Si estamos incluyendo extensiones de terceros probablemente esto sea lo mejor,
pero si la extensión la estamos haciendo nosotros puede que queramos evitarnos
tener que escribir este bloque y así mantener más limpio nuestro fichero
`pelicanconf.py` y de este modo solo pensar en `plugins` en general, sin hacer
distinción si son `plugins de pelican` o `extensiones de markdown`.

En definitiva, la idea es es crear la extensión dentro de un plugin.
Esto también es útil cuando queremos configurar la extensión en base a
variables de `pelicanconf.py` evitando tener que pasarlas por parámetro una a una.

Este sería un ejemplo para poder usar variables en `markdown`

En `pelicanconf.py`:

```python
import os
sys.path.append('.') #### 1
from plugins import replacements #### 2

abspath = os.path.abspath(__file__)
cur_dir = os.path.dirname(abspath)

REPLACEMENTS_CONFIG = cur_dir+"/config/replacements.yml" #### 3
PLUGINS=[replacements] #### 4

GITHUB_URL = 'https://github.com/s-nt-s/s-nt-s.github.io'
DEFAULT_PAGINATION = 10
```

* Con `1` y `2` incluimos el `plugin` que esta en `plugins/replacements.py`
* Con `3` definimos la variable que se usara para obtener el fichero de configuración
* Con `4` incluimos el `plugin`

En `plugins/replacements.py` tenemos:

```python
from markdown.preprocessors import Preprocessor
from markdown.extensions import Extension
from pelican import signals
import yaml

class MkReplace(Preprocessor):
    def __init__(self, delimiter, replacements):
        self.replacements = replacements
        self.delimiter = delimiter

    def run(self, lines):
        txt = "\n".join(lines)
        for key, value in self.replacements.items():
            txt = txt.replace(self.delimiter+key+self.delimiter, value)
        return txt.split("\n")


class ExReplace(Extension):
    
    def __init__(self, delimiter, replacements, **config):
        self.replacements = replacements
        self.delimiter = delimiter
        super(ExReplace, self).__init__(**config)

    def extendMarkdown(self, md, md_globals):
        md.preprocessors.add('replacements', MkReplace(self.delimiter, self.replacements), ">html_block")

def process_settings(pelican_object):
    config_file = pelican_object.settings['REPLACEMENTS_CONFIG'] #### 1
    with open(config_file, 'r') as stream:
        replacements = yaml.load(stream)
    if 'PELICAN_SETTINGS' in replacements:
        pSettings = replacements['PELICAN_SETTINGS']
        del replacements['PELICAN_SETTINGS']
        if isinstance(pSettings, str):
            pSettings = pSettings.strip().split()
        if isinstance(pSettings, list):
            for s in pSettings:
                if s not in replacements and s in pelican_object.settings:
                    replacements[s]=str(pelican_object.settings[s]) #### 2
    delimiter = replacements.pop('DELIMITER', '::')
    return delimiter, replacements

def replacements_markdown_extension(pelicanobj, delimiter, replacements):
    """Instantiates a customized Markdown extension"""
    pelicanobj.settings['MARKDOWN'].setdefault('extensions', []).append(ExReplace(delimiter, replacements))

def replacements_init(pelicanobj):
    """Loads settings and instantiates the Python Markdown extension"""
    # Process settings
    delimiter, replacements = process_settings(pelicanobj)

    # Configure Markdown Extension
    replacements_markdown_extension(pelicanobj, delimiter, replacements)

def register():
    """Plugin registration"""
    signals.initialized.connect(replacements_init)
```

* `register` registra el `plugin`
* `replacements_init` usa `pelicanobj` para preparar las opciones a través de `process_settings` y pasarselas a `replacements_markdown_extension`
* `replacements_markdown_extension` include la extensión de `markdown` en el `pelican` sin machacar los valores por defecto de la variable `MARKDOWN`
* El resto es el contenido habitual de una extensión `markdown`

En `process_settings` vemos como nos es de ayuda tener el objeto `pelican` disponible,
de manera que tenemos disponible `REPLACEMENTS_CONFIG` para encontrar el `yaml` de configuración (en `1`)
y a su vez podemos usar otras variables (en `2`) de manera que si el `yaml` es:

```
DELIMITER: '::'
PELICAN_SETTINGS: GITHUB_URL DEFAULT_PAGINATION
LOREM: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...
```

y tenemos un `markdown` tal que así:

```markdown
Este blog usa una imaginación de **::DEFAULT_PAGINATION::** items por hoja y
puedes encontrar el código en [github](::GITHUB_URL::)

::LOREN::
```

se transformara justo antes de ser pasado a `html` en:

```markdown
Este blog usa una imaginación de **10** items por hoja y
puedes encontrar el código en [github](https://github.com/s-nt-s/s-nt-s.github.io)

Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...
```

y finalmente en el `html`

```html
<p>Este blog usa una imaginación de <b>10</b> items por hoja y
puedes encontrar el código en <a href='https://github.com/s-nt-s/s-nt-s.github.io'>github</a></p>

<p>Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...</p>
```

Resumo las ventajas:

* menos lineas en `pelicanconf.py`
* no hay peligro de machacar valores por defecto de `MARKDOWN` necesarios
* la extensión tiene acceso al objeto `pelican` y por lo tanto a sus variables de configuración
* la extensión es más fácil de configurar
* no hace falta diferencia entre `extensiones markdown` y `plugins pelican`

Fuentes:
[docs.getpelican.com - settings](http://docs.getpelican.com/en/stable/settings.html#settings),
[docs.getpelican.com - plugins](http://docs.getpelican.com/en/stable/plugins.html#how-to-create-plugins),
[mi github :P](::GITHUB_URL::)
