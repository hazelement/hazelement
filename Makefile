
BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/pelicanconf.py
# PUBLISHCONF=$(BASEDIR)/publishconf.py
PELICANOPTS=

# executables
# PY?=$(BASEDIR)/pyenv/bin/python
# PELICAN?=$(BASEDIR)/pyenv/bin/pelican
# GHPIMPORT=$(BASEDIR)/pyenv/bin/ghp-import

VENV_NAME?=pyenv
PY?=$(BASEDIR)/$(VENV_NAME)/bin/python
PELICAN?=$(BASEDIR)/$(VENV_NAME)/bin/pelican
GHPIMPORT=$(BASEDIR)/$(VENV_NAME)/bin/ghp-import

FTP_HOST=localhost
FTP_USER=anonymous
FTP_TARGET_DIR=/

SSH_HOST=localhost
SSH_PORT=22
SSH_USER=root
SSH_TARGET_DIR=/var/www

S3_BUCKET=my_s3_bucket

CLOUDFILES_USERNAME=my_rackspace_username
CLOUDFILES_API_KEY=my_rackspace_api_key
CLOUDFILES_CONTAINER=my_cloudfiles_container

DROPBOX_DIR=~/Dropbox/Public/

GITHUB_STAGING_BRANCH=gh-pages
GITHUB_PAGES_REPO=git@github.com:hazelement/hazelement.github.io.git
GITHUB_PAGES_BRANCH=master

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

RELATIVE ?= 0
ifeq ($(RELATIVE), 1)
	PELICANOPTS += --relative-urls
endif


help:
	@echo 'Makefile for a pelican Web site                                           '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make prepare-dev                    prepare dev environment            '
	@echo '   make clean                          remove the generated files         '
	@echo '   make clean-git                      clean up git article branches      '
	@echo '   make html                           (re)generate the web site          '
	@echo '   make regenerate                     regenerate files upon modification '
	@echo '   make publish                        generate using production settings '
	@echo '   make devserver [PORT=8000]          run a auto-regenerate dev server   '
	@echo '   make ssh_upload                     upload the web site via SSH        '
	@echo '   make rsync_upload                   upload the web site via rsync+ssh  '
	@echo '   make dropbox_upload                 upload the web site via Dropbox    '
	@echo '   make ftp_upload                     upload the web site via FTP        '
	@echo '   make s3_upload                      upload the web site via S3         '
	@echo '   make cf_upload                      upload the web site via Cloud Files'
	@echo '   make github                         upload the web site via gh-pages   '
	@echo '                                                                          '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html   '
	@echo 'Set the RELATIVE variable to 1 to enable relative urls                    '
	@echo '                                                                          '


clean-git:
	git branch --merged | egrep -v "(^\*|master|dev|writing|theme)" | xargs git branch -d

prepare-dev:
	brew install python3
	python3 -m pip install virtualenv
	make prerequisites

prerequisites: $(VENV_NAME)/bin/activate

$(VENV_NAME)/bin/activate: requirements.txt
	test -d $(VENV_NAME) || virtualenv -p python3 $(VENV_NAME)
	${PY} -m pip install -U pip
	$(PY) -m pip install -r requirements.txt
	touch $(VENV_NAME)/bin/activate

html: prerequisites
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	rm -rf $(VENV_NAME)

regenerate: prerequisites
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

devserver: prerequisites
ifdef PORT
	$(PY) devserver.py $(CONFFILE) localhost $(PORT)
else
	$(PY) devserver.py $(CONFFILE) localhost 8000
endif

publish: prerequisites
	git push
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

ssh_upload: publish
	scp -P $(SSH_PORT) -r $(OUTPUTDIR)/* $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

rsync_upload: publish
	rsync -e "ssh -p $(SSH_PORT)" -P -rvzc --delete $(OUTPUTDIR)/ $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR) --cvs-exclude

dropbox_upload: publish
	cp -r $(OUTPUTDIR)/* $(DROPBOX_DIR)

ftp_upload: publish
	lftp ftp://$(FTP_USER)@$(FTP_HOST) -e "mirror -R $(OUTPUTDIR) $(FTP_TARGET_DIR) ; quit"

s3_upload: publish
	s3cmd sync $(OUTPUTDIR)/ s3://$(S3_BUCKET) --acl-public --delete-removed --guess-mime-type

cf_upload: publish
	cd $(OUTPUTDIR) && swift -v -A https://auth.api.rackspacecloud.com/v1.0 -U $(CLOUDFILES_USERNAME) -K $(CLOUDFILES_API_KEY) upload -c $(CLOUDFILES_CONTAINER) .

github: publish
	${GHPIMPORT} ${OUTPUTDIR} -b ${GITHUB_STAGING_BRANCH}
	git push ${GITHUB_PAGES_REPO} ${GITHUB_STAGING_BRANCH}:${GITHUB_PAGES_BRANCH} -f

.PHONY: html help clean regenerate devserver publish ssh_upload rsync_upload dropbox_upload ftp_upload s3_upload cf_upload github prerequisites clean-git prepare-dev
