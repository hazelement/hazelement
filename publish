#!/bin/bash
pelican content -o output -s pelicanconf.py
ghp-import output -b gh-pages

git push https://github.com/hazelement/hazelement.github.io.git gh-pages:master -f
