#!/bin/bash
pelican content -o output -s pelicanconf.py
ghp-import output -b gh-pages

git push git@github.com:hazelement/hazelement.github.io.git gh-pages:master -f

# or , publish is defined remote
# t push publish gh-pages:master -f