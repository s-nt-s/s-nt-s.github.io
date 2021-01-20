#!/usr/bin/python3
# -*- coding: utf-8 -*-

import re
from glob import iglob
from urllib.parse import urljoin

import requests
import yaml
from bs4 import BeautifulSoup

re_link1 = re.compile(r"!?\[.*?\]\(([^#].+?)\)")
re_link2 = re.compile(r'<img\b[^>]+src=["]([^"]+)')


def get_head(md):
    head = ''
    source = None
    with open(md, "r") as f:
        for l in f.readlines():
            head = head + l
            if l.startswith("SOURCE: "):
                source = l[8:].strip()
            if len(l) == 1:
                return (source, head)
    if source and not head.endswith("\n"):
        head = head + "\n"
    return (source, head)


def get_github_page(source):
    source = source.replace("/blob/", "/raw/")
    m = source.split("/")
    root = "/".join(m[:7])
    relt = "/".join(m[:-1]) + "/"
    fake_root = "https://this.is.a.fake.root/"
    r = requests.get(source)
    raw = r.text
    if re.search(r"^# ", raw, flags=re.MULTILINE):
        raw = re.sub(r"^#", "##", raw, flags=re.MULTILINE)
    rlp = set()
    for l in re_link1.findall(raw):
        if not l.startswith("#"):
            new_l = urljoin(fake_root, l)
            if new_l.startswith(fake_root):
                if l.startswith("/"):
                    new_l = root + l
                else:
                    new_l = relt + l
                rlp.add((l, new_l))
    rlp = sorted(rlp, key=lambda x: (len(x[0]), x[0], x[1]))
    for l, new_l in rlp:
        raw = raw.replace("(%s)" % l, "(%s)" % new_l)

    rlp = set()
    for l in re_link2.findall(raw):
        if not l.startswith("#"):
            new_l = urljoin(fake_root, l)
            if new_l.startswith(fake_root):
                if l.startswith("/"):
                    new_l = root + l
                else:
                    new_l = relt + l
                rlp.add((l, new_l))
    rlp = sorted(rlp, key=lambda x: (len(x[0]), x[0], x[1]))
    for l, new_l in rlp:
        raw = raw.replace('src="%s"' % l, 'src="%s"' % new_l)
    return raw


def get_header_footer(yml):
    header = yml.get("header", "")
    footer = yml.get("footer", "")
    header = header.replace("\\n", "\n")
    footer = footer.replace("\\n", "\n")
    if header and not header.endswith("\n"):
        header = header + "\n"
    if footer and not footer.startswith("\n"):
        footer = "\n" + footer
    return (header, footer)

def get_html_page(url, yml):
    r = requests.get(url)
    soup = BeautifulSoup(r.content, "lxml")
    avoid = yml.get("SOURCE_AVOID", [])
    for n in soup.findAll(["img", "form", "a", "iframe", "frame", "link", "script"]):
        attr = "href" if n.name in ("a", "link") else "src"
        if n.name == "form":
            attr = "action"
        val = n.attrs.get(attr)
        if val in avoid:
            pass
            #n.extract()
            #continue
        if val and not (val.startswith("#") or val.startswith("javascript:")):
            val = urljoin(url, val)
            n.attrs[attr] = val
    for h in range(5, 0, -1):
        for i in soup.findAll("h"+str(h)):
            i.name= "h"+str(h+1)
    body = soup.find("body")
    for s in reversed(soup.select("html > head > link[href]")):
        body.insert(0, s)
    for s in reversed(soup.select("html > head > script")):
        body.insert(0, s)
    body.name="div"
    return "\n"+str(body).strip()

for md in sorted(iglob("content/**/*.md")):
    source, head = get_head(md)
    if source:
        yml = yaml.load(head, Loader=yaml.FullLoader)
        print("Cargando %s\ndesde %s" % (md, source))
        ext = source.rsplit(".", 1)[-1].lower()
        if ext in ("html", "html"):
            raw = get_html_page(source, yml)
        else:
            raw = get_github_page(source)
        header, footer = get_header_footer(yml)
        with open(md, "w") as f:
            f.write(head)
            if header:
                f.write(header)
            f.write(raw)
            if footer:
                f.write(footer)
