#!/usr/bin/python3
import re

import bs4
from pelican import signals
from pelican.readers import MarkdownReader as MarkReader
from pelican.utils import pelican_open

re_tags = tuple(
    (t, re.compile(r"\b" + t + r"\b", re.IGNORECASE)) for t in
    ("linux", "python", "perl", "css", "php", "javascript", "pelican",
     "vlc", "raspberry", "raspbian", "noobs", "proxy", "owa", "transmission",
     "pyload", "cinnamon", "xfce", "lxde", "mint", "xmpp", "ethernet", "ip",
     "lan", "wlan", "markdown", "xbox", "gamepad", "php-download",
     "aircrack", "OpenWrt")
)
re_normalize = tuple(
    (t, re.compile(r"^(" + r + r")$", re.IGNORECASE)) for t, r in (
        ("Raspberry Pi", r"raspberry( *pi)?|raspbian|noobs"),
        ("redes", r"ethernet|ip|lan|wlan"),
        ("multimedia", "vlc"),
        ("videojuegos", "xbox|gamepad"),
        ("OpenWrt", "OpenWrt"),
        ("LFCS", "lfcs"),
        ("LFS201", "lfs201")
    )
)


def get_tag_normalized(tag):
    for t, r in re_normalize:
        if r.match(tag):
            return t
    return tag


def get_tags(content):
    tags = set()
    for tag, match in re_tags:
        if match.search(content):
            tags.add(tag)
    return tags


def clean_tags(remove_tags, *args):
    tags = set()
    for tag in args:
        tag = get_tag_normalized(tag)
        if tag not in remove_tags:
            tags.add(tag)
    return sorted(tags)


class MyReader(MarkReader):
    enabled = True
    file_extensions = ['md']

    def read(self, filename):
        output, metadata = super().read(filename)

        html = bs4.BeautifulSoup(output, "lxml")
        content = metadata['title'] + "\n" + html.get_text()
        tags = get_tags(content)
        remove_tags = set()
        for t in metadata.get("tags", []):
            if t.name.startswith("!"):
                remove_tags.add(t.name[1:])
            else:
                tags.add(t.name.lower())

        if len(tags) > 0:
            tags = clean_tags(remove_tags, *tags)
            metadata["tags"] = self.process_metadata("tags", ", ".join(tags))

        return output, metadata


def add_reader(readers):
    for ext in MyReader.file_extensions:
        readers.reader_classes[ext] = MyReader


def register():
    signals.readers_init.connect(add_reader)
