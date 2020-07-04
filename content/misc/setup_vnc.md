Title: Setup VNC
Date: 2020-07-04
Modified: 2020-07-04
Category: misc
Tags: VNC
Authors: Harry Zheng
Summary: Setup VNC server on Ubuntu 18.04

# Introduction

There a lot of times we need to remote access a server. VNC is one of the commonly used tools. I have a lot of troubles setting up VNC server before. Here are the notes I've collected to setup a functioning VNC server. 


# Glossary

* TightVNC
* xfce
* 

# Intallation

## Install desktop environment

In order to remote into server's desktop environment, we need to install a desktop environment first. We use `xfce` here. 

Install `xfce` and related components using following commands.

```
sudo apt updatesudo apt install xfce4 xfce4-goodies
```

## Install `TightVNC`

We use `TightVNC` as VNC server. 

```
sudo apt install tightvncserver
```

To initalize VNC server's configuration. Run following command as the user your will be login remotely. 

```
vncserver
```

A promot will ask your to enter and verify your remote password. 

```
You will require a password to access your desktops.

Password:
Verify:
```

After this, select `n` to not create a view-only password. 


## Configure `TightVNC`

First stop the `vncserver` that is running using default configuraiton file. 

```
> vncserver -kill :1
Killing Xtightvnc process ID 17648
```

Replace the configuration file `~/.vnc/xstartup` using following content. 

```
#!/bin/sh
/etc/X11/Xsession
def
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

xrdb $HOME/.Xresources
xsetroot -solid grey
autocutsel -fork
startxfce4 &

```

Set proper permission for this file, 

```
chmod +x ~/.vnc/xstartup
```

Restart the VNC server

```
> vncserver
New 'X' desktop is your_hostname:1

Starting applications specified in /home/vncuser/.vnc
```


## Run VNC as a system service

To setup VNC server to run automatically when system boots, we setup a system service. 

Create a new service unit file, `/etc/systemd/system/vncserver@.service`. Replace `<vnc_user>` with your remote user. 

```
# /etc/systemd/system/vncserver@.service


[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=<vnc_user>
Group=<vnc_user>
WorkingDirectory=/home/<vnc_user>

PIDFile=/home/<vnc_user>/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target

```

Reload system daemon. 

```
sudo systemctl daemon-reload
```


Enable the VNC service. 

```
sudo systemctl enable vncserver@1.service
```

The 1 following the @ sign signifies which display number the service should appear over, in this case the default :1.


Stop current running VNC server and restart it using system service. 

```
vncserver -kill :1
sudo systemctl start vncserver@1
sudo systemctl status vncserver@1

```

It should show the service is running. 


## Connect to VNC securely

VNC connect is not secured by default. We can secure it using SSH tunnel. 

```
ssh -L <local_port>:127.0.0.1:5901 -C -N -L <vnc_user> <server_ip>
```

And connect to the remote VNC server from your local port, `localhost:<local_port>`.