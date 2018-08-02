Using Pelican for Blogging
##########################

:date: 2016-11-27
:tags: reStructured text, python, Pelican
:authors: Harry Zheng




Pelican is a popular static website generator written in Python. It saves bloggers from worrying about formats so that they can focus on the content itself. Pelican to bloggers is like Latex to document writters. Pelican take advantage of Markdown and reStructured text (rst) to generated formatted texts. I wrote this website usig rst. Markdown is also a good option as well. 



Get started 
===========
Pelican has a great tutorial covering the basic steps to setup a website to play with. 
http://docs.getpelican.com/en/stable/quickstart.html.

Here is a brief summary of that page.

Installation
------------

To install pelican with pip:

.. code-block:: bash

	pip install pelican

If we are using markdown, we can install it with pip too:

.. code-block:: bash

	pip install markdown

Create a project
----------------
A directory must be created for our new project:

.. code-block:: bash
	
	mkdir -p ~/pelican_tutorial
	cd pelican_tutorial

Once we are in our project directory, we can create a project using the following command:

.. code-block:: bash

	pelican-quickstart

Pelican then will ask us a few questions regarding your website. Don't worry if we are not sure on some of these questions, all these options can be changed afterwards. An example of these questions are here:

.. code-block:: bash

	Welcome to pelican-quickstart v3.6.3.

	This script will help you create a new Pelican-based website.

	Please answer the following questions so this script can generate the files
	needed by Pelican.

	> Where do you want to create your new web site? [.] 
	> What will be the title of this web site? my_first_blog
	> Who will be the author of this web site? haze
	> What will be the default language of this web site? [en] 
	> Do you want to specify a URL prefix? e.g., http://example.com   (Y/n) n
	> Do you want to enable article pagination? (Y/n) y
	> How many articles per page do you want? [10] 
	> What is your time zone? [Europe/Paris] 
	> Do you want to generate a Fabfile/Makefile to automate generation and publishing? (Y/n) y
	> Do you want an auto-reload & simpleHTTP script to assist with theme and site development? (Y/n) y
	> Do you want to upload your website using FTP? (y/N) n
	> Do you want to upload your website using SSH? (y/N) n
	> Do you want to upload your website using Dropbox? (y/N) n
	> Do you want to upload your website using S3? (y/N) n
	> Do you want to upload your website using Rackspace Cloud Files? (y/N) n
	> Do you want to upload your website using GitHub Pages? (y/N) n
	Done. Your new project is available at /xxx/pelican_tutorial

Create an articles with category
--------------------------------
Next we are going to create our first post with a category specified. In plelican, each post is a rst file stored within the cotent directory. 

.. code-block:: bash

	~/pelican_tutorial/content

Although, categories can be specified within rst file similar to a tag. I prefer to take advantage of folders to put my rst files into each category. In the content folder, if we created folders and put our rst file in each sub folder. Then each folder will be considered as a category. 

.. code-block:: bash

	~/pelican_tutorial/tutorial

We just created a tutorial category. And let's create our first post under this category. 

.. code-block:: bash

	cd ~/pelican_tutorial/tutorial
	touch myfirst_tutorial.rst

We can then input content to this rst file. For example:

.. code-block:: rest

	My first tutorial
	########################

	:date: 2016-11-19 11:30
	:tags: reStructured text, rst
	:authors: Haze

	===== 
	Title 
	===== 
	Subtitle 
	-------- 
	This is a paragraph.

Save this file, and we are ready to generate our first post into html file.

Generate site
-------------
From site root directory

.. code-block:: bash

	cd ~/pelican_tutorial

Run the following code to generate your site:

.. code-block:: bash

	pelican content

A folder called output will be generated. This is where our site sits. 

To see how our site looks like, enter output directory:

.. code-block:: bash

	cd output

Run the local pelican server:

.. code-block:: bash

	python -m pelican.server

Open up web browser, and type in http://localhost:8000/, we should see the website served from local directory.

Some tips
=========

Autosite updates
----------------
Usually we would like to see our website updates live while we changing the rst file contents, especially during development. This can be achieved by running the following command. 

.. code-block:: bash

	make regenerate

"make" is a script at the project root folder. Don't close terminal after running this command as the script is monitoring our project folder to detect any changes. We can continous editing and saving your rst file. All changes will be reflected on your local website. Althought we need to refresh the page of course. One drawback with this script is that if we have a syntax error in the rst file, it will likely crash the script and we would have to restart it again after fixing the syntax. For popular rst syntax, check out my other post, `reStructured Text Syntax <{filename}/reStructuredText/rst_syntax.rst>`_.

Next up, `Setup Pelican for Github User Pages <{filename}/Pelican/pelican_ghpage.rst>`_.


