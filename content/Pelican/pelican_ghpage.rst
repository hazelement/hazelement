Setup Pelican for Github User Pages
###################################

:date: 2016-11-27
:tags: github, Pelican, ssh
:authors: Harry Zheng

For those who don't know. Github has this Pages utility which allow each user to setup a personal sub-domain under Github, functioning like a personal blog. It uses a unique git repo for each user to server its file content. For details, check out their website, https://pages.github.com. There are two types of Github Pages, Project Pages and User Pages. Setting up Project Pages is straight forward. I will be discussing setting up User Pages and some tricks I used to streamline the publishing process.

About Github Pages
==================

Files of a Github page reside in a very specific Github repository that is owned and unique to each user. They look like this format, yourname.github.io, where "yourname" is your Github name. The repository has to follow this format otherwise, it won't work. 

Go ahead and create a new repository named yourname.github.io. 

Once that's setup, you can see it on your Github profile and it is waiting for a init push. Now let's get back to our Pelican project. We don't need to clone it to our local disk.

Pushings Pelican Output to Github Repo
======================================

.. _ghp-import: https://github.com/davisp/ghp-import

The idea is basically to push Pelican's output folder to the Github repository we just created. To achive this, we have a great tool called ghp-import_. We can install it easily with the following command:

.. code-block:: bash

	pip install ghp-import

A normal command using ghp-import is like follows:

.. code-block:: bash

	pelican content -o output -s pelicanconf.py
	ghp-import output
	git push git@github.com:username/username.github.io.git gh-pages:master

The first line generate all rst documents into our output folder. ghp-import then import this output folder into a git branch called gh-pages. 

Then the last line push this branch to its remote repository which is our Github User Pages repo, yourname.github.io. gh-pages is our local branch and master is our remote repository branch. Please note that the remote branch must be the master branch for it to work properly.

The last command will prompt your enter your username and password. Simply enter that, our output folder should be pushed to the repo successfully. Now open up browser and enter username.github.io and we can see our blog live on the web.

Github 2-step Authentification
==============================

If you have 2-step Authentification setup on Github account, using the git push command might not work for you as it doesn't implement a way for you to enter the second passcode. 

There are 2 ways to solve this problem, one way is to generate a app hash string passcode from Github and use it while doing git push. It's annoying as we have to keep that somewhere and we need to enter that everytime we perform a push. 

Another easier way is to generate a ssh and put your public key to github. 

Github SSH Access
=====================
There are many tutorials on how to generate a SSH key pair. A SSH key pair contains a private key and a public key. 

A private key is our personal key and we should alway keep secret. A public key is like a lock that matches our private key. When we need to access some machine remotely, we give public key to remote mahine manager and he can install it to his machine. It's like installing our lock onto his house's front door (in this case, his house would be the machine). So we can get into his house with our prviate key. And of course, he can setup locks that comes from other people, ie his door can have many locks and each lock can open his door. 

If you are using a linux machine, a quick way to generate a key pair is to use ssh-keygen. 

.. code-block:: bash

	ssh-keygen -t rsa -C "your_email@example.com"

This will generate two files, id_rsa, and id_rsa.pub. Open id_rsa.pub with any text editor and copy its entire content. 

Now let's put this public key to our Github account so that we can use our private key to access Github. 

In https://github.com/settings/keys, we have a section to add new public key. Paste everything from public key into "Key" section and name "title" to "mySSHKey". And click on add SSH key. We should be good to go. 

Next time when we do a git push, it should stop asking us about our password. 

Streamline With A Script
========================

We can stream line the publishing process with a bash script. Let's first go to our project root folder and create a file called pubish. 

.. code-block:: bash

	touch publish

In this file, let's enter the following content

.. code-block:: bash

	#!/bin/bash
	pelican content -o output -s pelicanconf.py
	ghp-import output
	git push git@github.com:username/username.github.io.git gh-pages:master

Making this file executable:

.. code-block:: bash

	chmod +x publish

We just created a script to perform the publishing process for us. To publish new content, simply enter this command under project root directory.

.. code-block:: bash

	./publish

It should perform all the task for us.











