import yaml
from markdown.extensions import Extension
from markdown.preprocessors import Preprocessor
from pelican import signals


class MkReplace(Preprocessor):

    def __init__(self, delimiter, replacements):
        self.replacements = replacements
        self.delimiter = delimiter

    def run(self, lines):
        txt = "\n".join(lines)
        for key, value in self.replacements.items():
            txt = txt.replace(self.delimiter + key + self.delimiter, value)
        return txt.split("\n")


class ExReplace(Extension):

    def __init__(self, delimiter, replacements, **config):
        self.replacements = replacements
        self.delimiter = delimiter
        super(ExReplace, self).__init__(**config)

    def extendMarkdown(self, md, md_globals):
        md.preprocessors.add('replacements', MkReplace(
            self.delimiter, self.replacements), ">html_block")


def process_settings(pelican_object):
    config_file = pelican_object.settings['REPLACEMENTS_CONFIG']
    relativeURL = pelican_object.settings.get("RELATIVE_URLS", False)
    with open(config_file, 'r') as stream:
        replacements = yaml.load(stream, Loader=yaml.FullLoader)
    if 'PELICAN_SETTINGS' in replacements:
        pSettings = replacements['PELICAN_SETTINGS']
        del replacements['PELICAN_SETTINGS']
        if isinstance(pSettings, str):
            pSettings = pSettings.strip().split()
        if isinstance(pSettings, list):
            for s in pSettings:
                if s not in replacements and s in pelican_object.settings:
                    v = pelican_object.settings[s]
                    if relativeURL and s == "SITEURL":
                        v = ""
                    replacements[s] = str(v)
    delimiter = replacements.pop('DELIMITER', '::')
    return delimiter, replacements


def replacements_markdown_extension(pelicanobj, delimiter, replacements):
    """Instantiates a customized Markdown extension"""
    pelicanobj.settings['MARKDOWN'].setdefault(
        'extensions', []).append(ExReplace(delimiter, replacements))


def replacements_init(pelicanobj):
    """Loads settings and instantiates the Python Markdown extension"""
    # Process settings
    delimiter, replacements = process_settings(pelicanobj)

    # Configure Markdown Extension
    replacements_markdown_extension(pelicanobj, delimiter, replacements)


def register():
    """Plugin registration"""
    signals.initialized.connect(replacements_init)
