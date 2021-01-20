#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

import os
import sys

sys.path.append('.')

from myplugins import reader, replacements, mod_html, set_count, mod_content
from myplugins.jinja_filters import JINJA_FILTERS

sys.path.append('.')

abspath = os.path.abspath(__file__)
cur_dir = os.path.dirname(abspath)

AUTHOR = 's-nt-s'
SITENAME = 'Apuntes'
SITESUBTITLE = '(mejor aquí que en un txt perdido)'
SITEURL = 'https://s-nt-s.github.io'
GITHUB_URL = 'https://github.com/s-nt-s/s-nt-s.github.io'
SOURCE_URL = GITHUB_URL+'/tree/source'
MAPA_URL = 'mapa'

'''
SCOPE_ENVIRON='SNTS_'

for v in ('SITEURL',):
    ENVIRON_VAR = SCOPE_ENVIRON+v
    if ENVIRON_VAR in os.environ:
        exec('%s = "%s"' % (v, os.environ[ENVIRON_VAR]))
'''
SITEURL = os.environ.get('URL', SITEURL)

# LEN_CUR_DIR se usa para hacer relativas rutas como source_path
LEN_CUR_DIR = len(cur_dir)+1

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

TIMEZONE = 'Europe/Madrid'

DEFAULT_LANG = 'es'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

DISPLAY_PAGES_ON_MENU = False
DISPLAY_CATEGORIES_ON_MENU = False

PAGE_OUT = 'p/'

MENUITEMS = (
    ('About', PAGE_OUT + 'about'),
    ('Mapa', MAPA_URL),
    ('Ver Github', SOURCE_URL),)

# Social widget
SOCIAL = (
    ('@s-nt-s', 'https://github.com/s-nt-s/'),
    ('git@suchat.org', 'xmpp:git@suchat.org'),)

#DEFAULT_PAGINATION = 10

FEED_ALL_ATOM = 'feeds/all.atom.xml'
#FEED_ALL_RSS = 'feeds/all.rss.xml'
#AUTHOR_FEED_RSS = 'feeds/%s.rss.xml'
RSS_FEED_SUMMARY_ONLY = False

DEFAULT_DATE_FORMAT = '%Y-%m-%d'

DIRECT_TEMPLATES = ['index', 'categories',
                    'tags', 'sitemap', 'map']
AUTHOR_SAVE_AS = False
SITEMAP_SAVE_AS = 'sitemap.xml'
MAP_SAVE_AS = MAPA_URL + '/index.html'

PATH = 'content'

PAGE_PATHS = ['pages']
ARTICLE_PATHS = ['posts']

ARTICLE_URL = '{slug}/'
ARTICLE_SAVE_AS = '{slug}/index.html'
PAGE_URL = PAGE_OUT + '{slug}/'
PAGE_SAVE_AS = PAGE_OUT + '{slug}/index.html'

FILENAME_METADATA = '(?P<date>\d{4}-\d{2}-\d{2})[\-_](?P<slug>.*)'

STATIC_PATHS = [
    'images',
    'extra/robots.txt',
    'extra/favicon.ico',
    'extra/CNAME'
]
EXTRA_PATH_METADATA = {
    'extra/robots.txt': {'path': 'robots.txt'},
    'extra/favicon.ico': {'path': 'favicon.ico'},
    'extra/CNAME': {'path': 'CNAME'}
}

THEME = cur_dir + '/themes/notmyidea-custom'

REPLACEMENTS_CONFIG = cur_dir + "/config/replacements.yml"
PLUGINS = [reader, replacements, mod_html, set_count, mod_content]
