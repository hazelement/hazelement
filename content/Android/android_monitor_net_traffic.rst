Sniff Android Network Traffic on Rooted Device Using Tcpdump and Netcat
###################################################

:date: 2016-12-28
:tags: Jenkins, Django, Continous Deployment
:authors: Harry Zheng

There are many ways to sniff network traffic on android, VPN, proxy and etc. Today we are gonna look into using tcpdump to sniff urls that users visits and using netcat to stream the data to a socket for another app to read.


The Linux binaries
==================

We will be using two Linux binaries to achive this, tcpdump and netcat. Tcpdump is a popular tool in Linux to capture net traffic. Netcat is another Linux binary that are commonly used to listen on a socket. We will be using these two binaries along with Java coded android apps to demonstrate the technique.


A Rooted Android Phone
======================
First thing first, this technique requires a rooted android phone. If your phone is not rooted, check out some posts and root your device first. 

Compile Tcpdump and Netcat Binaries for Android
===============================================
Like any other binaries written in C, we need to compile them differerntly if we want to run them on differernt platforms. 

Let's start by installing our android compiler, assuming we are compiling for arm processor architecture. Execute the following command in your Ubuntu shell. 

.. code-block:: bash

	sudo apt-get install gcc-arm-linux-gnueabi
	sudo apt-get install byacc
	sudo apt-get install flex

This will install gcc for arm architectre and other support tools for compiling. 

Next, create a folder named "compile_for_android", this is where we will be performing all the compiling. 

.. code-block:: bash

	mkdir compile_for_android
	cd compile_for_android

Now let's download tcpdump source code. 

.. code-block:: bash

	wget http://www.tcpdump.org/release/tcpdump-4.8.1.tar.gz

Tcpdump depends on libpcap, so we need to download and compile libpcap source code as well. 

.. code-block:: bash

	wget http://www.tcpdump.org/release/libpcap-1.8.1.tar.gz

Extract these two packages. 

.. code-block:: bash

	tar zxvf tcpdump-4.8.1.tar.gz
	tar zxvf libpcap-1.8.1.tar.gz

Now we are ready to compile our tcpdump. 

First, let's make sure our compiler is the android compiler. 

.. code-block:: bash

	export CC=arm-linux-gnueabi-gcc

Compiler libpcap first. 

.. code-block:: bash

	cd libpcap-1.8.1
	./configure --host=arm-linux --with-pcap=linux
	make

This should compiler the libpcap library for us. Now let's go to our tcpdump directory. 

.. code-block:: bash

	cd ..
	cd tcpdump-4.8.1

Before we perform the same thing above, there is a few things we need to do. 

Figure out what major version our Ubuntu we have, 

.. code-block:: bash

uname -a

This will give out something like this. 

.. code-block:: bash

	4.2.0-42-generic

In this case, our major version is 4 and we set a variable in command. 

.. code-block:: bash

	export ac_cs_linux_vers=4

Set the following variables to make our binary self contained (ie. not reliant on other libraries).

.. code-block:: bash

	export CFLAGS=-static
	export CPPFLAGS=-static
	export LDFLAGS=-static

And configure the directory, 

.. code-block:: bash

	./configure --host=arm-linux --disable-ipv6

And then make it, 

.. code-block:: bash

	make

Strip the symbol information to make binary smaller. These symbols are only useful in debugging the application. 

.. code-block:: bash

	arm-linux-gnueabi-strip tcpdump







Our development code will be sitting at ~/django_hello_world. 

For simplicity, the source code will be pushed to a git repository that is sitting on the same machine at /webapp_repo. It can be on other machine through a ssh tunnel. 

The production code, which is also our live code, will be sitting at /webapps/django_hello_world


Django Hello World
==================

First thing first, we need to setup an web application first. This will be a similar version of the official Django tutorial, https://docs.djangoproject.com/en/1.10/intro/tutorial01/.

Start the Django project:

.. code-block:: bash

	cd ~/django_hello_world
	django-admin startproject hello_world

Under the same directory, create an app called polls:

.. code-block:: bash

	python manage.py startapp polls

This will create a folder called polls. Under polls, open up the file called views and put the following code:

.. code-block:: python
	
	from django.http import HttpResponse

	def index(request):
    	return HttpResponse("Hello, world. You're at the polls index.")

In the same polls folder, create a file named "urls.py" which will define the urls. In the urls file, enter the following code:

.. code-block:: python

	from django.conf.urls import url

	from . import views

	urlpatterns = [
	    url(r'^$', views.index, name='index'),
	]

Now let's link this url file to the global url file. Open up the urls.py file under hello world folder and put in the following code:

.. code-block:: python

	from django.conf.urls import url, include
	from django.contrib import admin

	urlpatterns = [
	    url(r'^polls/', include('polls.urls')),
	    url(r'^admin/', admin.site.urls),
	]

And that's it! Go back to project root directory:

.. code-block:: bash

	cd ~/django_hello_world

And run this command:

.. code-block:: bash

	python manage.py runserver


Open up http://localhost:8000/polls/ in the browser and we should see the text "Hello, world. You're at the polls index."

Remember this only runs our web application under local host, and only we can see it. In order for other people to see it, we need to use apache to serve it. 


Serve Django with Apache 
========================
Django's tutorial website has a thorough documentation on the setup, https://docs.djangoproject.com/en/1.10/howto/deployment/wsgi/modwsgi/. We will briefly mention it here. 

Using mod_wsgi daemon mode is the recommended way to serve our application. Assuming we have apache and mod_wsgi installed. 

First of all, let's create a directory to store our production files where Jenkins will be publishing to. 

.. code-block:: bash

	cd /
	mkdir /webapps/hello_world

Our production code will be sitting under this directory,

.. code-block:: bash

	hello_world/
		hello_world/
		polls/
		...


Under apache's enabled site directory, let's create a conf file for our web application. 

.. code-block:: bash

	cd /etc/apache2/sites-enabled
	touch hello_world.conf

In hello_world.conf, enter the following contents,

.. code-block:: bash

	Listen 8888
	<VirtualHost *:8888>
	        # The ServerName directive sets the request scheme, hostname and port that
	        # the server uses to identify itself. This is used when creating
	        # redirection URLs. In the context of virtual hosts, the ServerName
	        # specifies what hostname must appear in the request's Host: header to
	        # match this virtual host. For the default virtual host (this file) this
	        # value is not decisive as it is used as a last resort host regardless.
	        # However, you must set it for any further virtual host explicitly.
	        #ServerName www.example.com

	        # ServerAdmin webmaster@localhost
	        # DocumentRoot /var/www/html

	        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	        # error, crit, alert, emerg.
	        # It is also possible to configure the loglevel for particular
	        # modules, e.g.
	        # LogLevel info ssl:warn


	        WSGIScriptAlias / /webapps/hello_world/hello_world/wsgi.py
	        WSGIDaemonProcess helloworld.com python-path=/django_hello_world
	        WSGIProcessGroup helloworld.com
	        <Directory> /webapps/hello_world/hello_world>
	                <Files wsgi.py>
	                Require all granted
	                </Files>
	        </Directory>

	        ErrorLog ${APACHE_LOG_DIR}/error.log
	        CustomLog ${APACHE_LOG_DIR}/access.log combined

	        # For most configuration files from conf-available/, which are
	        # enabled or disabled at a global level, it is possible to
	        # include a line for only one particular virtual host. For example the
	        # following line enables the CGI configuration for this host only
	        # after it has been globally disabled with "a2disconf".
	        #Include conf-available/serve-cgi-bin.conf
	</VirtualHost>

This document tells apache about configurations of our site. Apache will be listening on port 8888 and our site should be accessible on port 8888 at all IP addresses.
There is a wsgi.py file we need to create for apache to load the Django application. Go back to our development directory,

.. code-block:: bash

	cd ~/django_hello_world/hello_world
	cd hello_world
	touch wsgi.py

The file structure should look like this,

.. code-block:: bash

	hello_world/
		hello_world/
			wsgi.py
			...
		polls/
		...

In wsgi.py, enter the following content,

.. code-block:: python

	import os
	from django.core.wsgi import get_wsgi_application

	os.environ.setdefault("DJANGO_SETTINGS_MODULE", "hello_world.settings")
	application = get_wsgi_application()


And that's it, we are set for apache. Now let's get our code into our production directory.

Setup Git Repository
================================

Next setup is to setup the git repository and pull code to our production directory. For simplicity, we will setup the git repository as a local directory on our machine. 

.. code-block:: bash

    cd /
    mkdir git_repo
    cd git_repo
    git init --bare hello_world.git

This will setup a local git repository under /git_repo called hello_world.git. Next, let setup our development code to track this directory and push our code to it. 

.. code-block:: bash

	cd /django_hello_world/hello_world
	git remote add origin /git_repo/hello_world.git

Make our first commit by typing,

.. code-block:: bash

	git status
	git add --all
	git commit -a

Type in our first commit message and finish the commit. Next let's push our first commit to git repository,
	
.. code-block:: bash

	git push -u origin master

This will push our commit to remote called origin and setup our local master to track the remote master branch. Next let's pull our code into our production directory.

.. code-block:: bash

	cd /webapps
	git clone /git_repo/hello_world.git

Our lastest code should show up in the webapps directory. This is also where apache will be accessing our site code. Restart apache server, 

.. code-block:: bash

	sudo systemctl restart apache2

Now, we should be able to see the site under 8888 port, try localhost:8888 or 127.0.0.1:8888 in our web browser. 

Setup Jenkins to Link Everything
================================

First thing first, let's install Jenkins. Follow the instructions on the website, https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu. 

.. code-block:: bash

	wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
	sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get update
	sudo apt-get install jenkins

Jenkins need JDK and JRE installed to run, install them first if your machine doesn't have them.

After installation, check status of Jenkins and make sure it's running,

.. code-block:: bash

	sudo service jenkins status

If Jenkins is not running, start it with,


.. code-block:: bash
	
	sudo service jenkins start

Now, open up browser and go to localhost:8080, this is where Jenkins is served. At first time, Jenkins will ask your to create an admin account, just follow the steps to create the admin account. 

Create a New Build Configuration
--------------------------------

At Jenkins's home page, click **New Item** to create an entry for our project. Enter "hellow world" for the item name and select **Freestyle project**.

On the next pages, where are a few tabs we need to go through. 

Under **Source Code Management**, select **Git**. A new sub window will appear. Enter "/git_repo/hello_world.git" for *Repository URL**. This is where we setup our git repository. 

Leave **Credentials** as "none" as we don't have authentification to access this repository. Leave **Brances to build** as "\*/master".

Under **Build Triggers**, check **Build periodically**, and enter "H/10 \* \* \* \*" fpr **Schedule**, this will check for any changes every 10 minutes. Also check **Build when a change is pushed to GitHub**, this will trigger Jenkins to run whenever a change checked in.

Under **Build**, this is where we will be entering our build script, type in the following,

.. code-block:: bash 

	cd /webapps/hello_world
	python manage.py migrate
	python manage.py test --noinput hello_world polls
	sudo systemctl restart apache2

This is also where we can run our test scripts before make our changes live. 

Click **save** and we should be good.

In the next page, which is also where our project dash board, click **Build Now** and once its finished, we can see the latest build result under **Build History**.


Make a Simple Change and See It Becomes Live
--------------------------------------------

Let's make a change to our source code and test if our Jenkins does the job. 

.. code-block:: bash

	cd ~/django_hello_world/hello_world/polls

In the "views.py" file, we had the code as following, 

.. code-block:: python

	from django.http import HttpResponse

	def index(request):
    	return HttpResponse("Hello, world. You're at the polls index.")

.. code-block:: python

	from django.http import HttpResponse


	def index(request):
	    return HttpResponse("Hello, world. You're at the polls index. An update on the polls index from Jenkins")

Commit and push the new changes,

.. code-block:: bash

	git commit -a
	git push

Now go to localhost:8888, we should be able to see our change becomes live once Jenkins finish the new build. 

And that's it, we just setup our first continous integration system.


















