#!/usr/bin/python3
# -*- coding: utf-8 -*-

import glob
import os

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)


def get_new_name(f):
    date = None
    slug = None
    with open(f, "r") as f:
        for l in f.readlines():
            l = l.strip()
            if len(l) == 0:
                return
            if ":" in l:
                key, value = [i.strip().lower() for i in l.split(":", 1)]
                if key == "date":
                    date = value.split(" ")[0]
                elif key == "slug":
                    slug = value
            if date and slug:
                return date + "_" + slug + ".md"
    return None


d = {}

for f in glob.iglob('content/**/*.md', recursive=True):
    dir_name = os.path.dirname(f)
    old_name = os.path.basename(f)
    new_name = get_new_name(f)
    if new_name is not None and old_name != new_name:
        renames = d.get(dir_name, set())
        renames.add((old_name, new_name))
        d[dir_name] = renames

for dir_name, renames in sorted(d.items()):
    print(dir_name)
    for old_name, new_name in sorted(renames):
        print("  %s -> %s" % (old_name, new_name))
        os.rename(dir_name + "/" + old_name, dir_name + "/" + new_name)
