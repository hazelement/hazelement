#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Haze'
SITENAME = u'Coding Digests'
SIDEBAR_DIGEST = u"A bit from everyday"
SITEURL = 'https://hazelement.github.io/'
# SITEURL = 'http://localhost:8000'

PATH = 'content'

TIMEZONE = 'America/Chihuahua'

DEFAULT_LANG = u'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

PLUGIN_PATHS = ['plugins',]
PLUGINS = ['tipue_search',]
DIRECT_TEMPLATES = (('index', 'tags', 'categories', 'authors', 'archives', 'search'))

STATIC_PATHS = [
    'images', 
    'extra/favicon.ico'
]
EXTRA_PATH_METADATA = {
    'extra/favicon.ico': {'path': 'favicon.ico'}
}


# Blogroll
# LINKS = (('Pelican', 'http://getpelican.com/'),
#          ('Python.org', 'http://python.org/'),
#          ('Jinja2', 'http://jinja.pocoo.org/'),
#          ('You can modify those links in your config file', '#'),)
LINKS = ()

# Social widget
SOCIAL = (('You can add links in your config file', '#'),
          ('Another social link', '#'),)

DEFAULT_PAGINATION = 10

SUMMARY_MAX_LENGTH = 50

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

THEME = "themes/pelican-blue"
# THEME = "simple"

# Following items are often useful when publishing
# DISQUS_SITENAME = ""
DISQUS_SITENAME = "https-hazelement-github-io.disqus.com"
#GOOGLE_ANALYTICS = ""

IDEBAR_DIGEST = 'Programmer and Web Developer'

FAVICON = '/favicon.ico'

MENUITEMS = (('Home', '/'),)

# Display pages list on the top menu
DISPLAY_PAGES_ON_MENU = True

# Display categories list on the top menu
DISPLAY_CATEGORIES_ON_MENU = False

# Display categories list as a submenu of the top menu
DISPLAY_CATEGORIES_ON_SIDEBAR = True
DISPLAY_TAGS_ON_SIDEBAR = True

# Display the category in the article's info
DISPLAY_CATEGORIES_ON_POSTINFO = True



# Display the author in the article's info
DISPLAY_AUTHOR_ON_POSTINFO = True

# Display the search form
DISPLAY_SEARCH_FORM = True

# Sort pages list by a given attribute
# PAGES_SORT_ATTRIBUTE = Title 

# Display the "Fork me on Github" banner
GITHUB_URL = None

# Blogroll
LINKS 

# Social widget
SOCIAL = (
          ('github', 'https://github.com/hazelement'),
          )