Title: Dot file Management
Date: 2020-05-03
Modified: 2020-05-03
Category: misc
Tags: dot file
Authors: Harry Zheng
Summary: Backup and Restore dot files

# Introduction

Developers have a lot of personalized configuration files, from shell profile, git configuration to IDE configurations. A lot of times, when we get a new machine, we need to configure the machine to our likes using this dot files. However, managing these files could be a pain. 

`yadm` is a project aim to solve this problem, https://yadm.io/. It's built onto of git so it has our favorite version control system. 

# Using `yadm`

## Installing `yadm`

On MacOS, we can install `yadm` using `brew`.

```
brew instsall yadm
```

On Ubuntu/Debian, we install `yadm` using `apt-get`. 


## Configure `yadm`

### Start fresh without a remote repository

Start with an empty local repository, 

```
yadm init
yadm add <important file>
yadm commits
```

It works the same as git because it's built on top of git. Eventually, we want to back up everything to a remote repository. 

Create a git repository of your choice, for example, Github. Push local repo to this remote. 

```
yadm remote add origin <url to git repo>
yadm push -u origin master
```

Next time to push an update, just do `yadm push`. 

### Using an existing remote repository

If you already has an remote repository that stores your dot files. Simply clone it to your current machine. 

```
yadm clone <url to git repo>
yadm status
```

## Common commands

We list some common commands below. 

### `yadm status`

Show current local repo status, similar to `git status`.

### `yadm commit`

Commit local changes. 

### `yadm add <path to file>`

Track a new file. 

### `yadm push, pull, clone`

Push to, pull or clone from remote repo.

### `yadm remote add origin <remote rpo>`

Add a remote repo. 

## Advanced topics

There are most advanced features in `yadm`. You can find them at https://yadm.io/docs/bootstrap. Some notable features are. 

* **Bootstrap**, setting up a bootstrap script that automatically configures machine for you
* **Encryption**, encrypt sensitive files such as SSH keys. It has symmetric and asymmetric encryption option. 

