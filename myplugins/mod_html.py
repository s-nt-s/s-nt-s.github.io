from os import walk
from os.path import join
from urllib.parse import urlparse

import bs4
from joblib import Parallel, delayed
from pelican import signals


def parallel_mod_html(pelican_object):
    html_files = []
    for dirpath, _, filenames in walk(pelican_object.settings['OUTPUT_PATH']):
        html_files += [join(dirpath, name)
                       for name in filenames if name.endswith('.html') or name.endswith('.htm')]

    SITEURL = pelican_object.settings.get('SITEURL', None)
    DOMAIN = urlparse(SITEURL).netloc if SITEURL else None
    Parallel(n_jobs=-1)(delayed(mod_html)(filepath, SITEURL, DOMAIN)
                        for filepath in html_files)


def set_target(html, SITEURL, DOMAIN):
    if DOMAIN is None:
        return False
    ok = False
    for a in html.select("a[href]"):
        if "target" not in a.attrs:
            a_dom = urlparse(a.attrs["href"]).netloc
            if len(a_dom) > 0 and a_dom != DOMAIN:
                a.attrs["target"] = "_blank"
                ok = True
    return ok

def move_script(html):
    ok = False
    head = html.find("head")
    for script in html.select("body script"):
        head.append(script)
        ok = True
    for script in html.select("body link[href]"):
        head.append(script)
        ok = True
    return ok

def rm_domain(html, SITEURL, DOMAIN):
    if DOMAIN is None:
        return False
    ok = False
    for a in html.findAll(["link", "a", "script", "img", "iframe", "frame"]):
        attr = "href" if a.name in ("a", "link") else "src"
        href = a.attrs.get(attr)
        if href is None:
            continue
        slp = href.split("://", 1)
        if len(slp)==2 and slp[0].lower() in ("http", "https"):
            a_dom = urlparse(href).netloc
            if a_dom == DOMAIN:
                slp = slp[1].split("/", 1)
                if len(slp)==2:
                    path = slp[1].rstrip("/")
                else:
                    path = ""
                a.attrs[attr] = "/" + path
                ok = True
    return ok

def mod_html(filename, SITEURL, DOMAIN):
    with open(filename, encoding='utf-8') as f:
        html = bs4.BeautifulSoup(f, "lxml")

    ok = True in (
        move_script(html),
        set_target(html, SITEURL, DOMAIN),
        rm_domain(html, SITEURL, DOMAIN)
    )

    if ok:
        with open(filename, "w", encoding='utf-8') as f:
            f.write(str(html))


def register():
    signals.finalized.connect(parallel_mod_html)
