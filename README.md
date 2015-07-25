# Base configuration
Linux configuration files for ease of use with installation instructions for fast installation.

## Cygwin
For those instances where you don't want to go through the hassle of setting up a seperate linux installation.
Download the latest version from the [cygwin website](https://www.cygwin.com/).
During the installation select following packages:
 - NCurses (for the 'clear' command)
 - Vim 7.4
 - Tmux
 - OpenSsh
 - Git
 - Git-completion

We will assume throughout the instructions that we are working with Cygwin but usually it is easier on other linux distributions :-)


## installation
```
git clone https://github.com/MathiasVE/conf.git
```
Follow the [GitHub ssh key generation instructions](https://help.github.com/articles/generating-ssh-keys/#platform-linux).
