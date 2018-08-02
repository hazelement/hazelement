#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

import os
import sys
sys.path.append(os.curdir)
from pelicanconf import *

SITEURL = 'n'
RELATIVE_URLS = False

FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'

DELETE_OUTPUT_DIRECTORY = True

# Following items are often useful when publishing

#DISQUS_SITENAME = ""
DISQUS_SITENAME = "https-hazelement-github-io.disqus.com"
#GOOGLE_ANALYTICS = ""

# Display pages list on the top menu
DISPLAY_PAGES_ON_MENU (True)

# Display categories list on the top menu
DISPLAY_CATEGORIES_ON_MENU (False)

# Display categories list as a submenu of the top menu
DISPLAY_CATEGORIES_ON_SUBMENU (True)

# Display the category in the article's info
DISPLAY_CATEGORIES_ON_POSTINFO (False)

# Display the author in the article's info
DISPLAY_AUTHOR_ON_POSTINFO (False)

# Display the search form
DISPLAY_SEARCH_FORM (True)

# Sort pages list by a given attribute
PAGES_SORT_ATTRIBUTE (Title)

# Display the "Fork me on Github" banner
GITHUB_URL (None)

# Blogroll
LINKS 

# Social widget
SOCIAL