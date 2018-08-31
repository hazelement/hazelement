Compile tcpdump for android.
###################################################

:date: 2016-12-28
:tags: Android, tcpdump, networking
:authors: Harry Zheng

There are many ways to sniff network traffic on android, VPN, proxy and etc. Today we are gonna look into using compiling tcpdump for Android which can be used with netcat to sniff network traffic later.


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


















