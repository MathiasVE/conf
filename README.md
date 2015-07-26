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
 - psmisc (for the 'pstree' command)
 - procps (for the 'top' command)
 - wget

We will assume throughout the instructions that we are working with Cygwin but usually it is easier on other linux distributions :-)

## Installation
```
git clone --recursive https://github.com/MathiasVE/conf.git .
```
Follow the [GitHub ssh key generation instructions](https://help.github.com/articles/generating-ssh-keys/#platform-linux).

## Gitignore
Create the git-ignore file.
```
vim .gitignore
```
And put following contents inside
```
.bash_history¬
.bashrc¬
.inputrc¬
.minttyrc¬
.profile¬
.viminfo¬
.gitignore
.gitconfig
.fonts¬
powerline-fonts
```

## Fonts
Fetch the powerline fonts
```
mkdir powerline-fonts
cd powerline-fonts
git clone https://github.com/powerline/fonts.git .
./install.sh
```

For Cygwin you need to manually install the 'Droid Sans Mono for Powerline' font (or any that you prefer) on windows.
Then you right-click on the cygwin console and select 'text' in the options overview.
Here you select the installed font and depending on the computer I prefer to increase the font-size.
Also change the cursor to 'block' under 'looks'

## Git-flow
```
wget -q -O - --no-check-certificate https://github.com/nvie/gitflow/raw/develop/contrib/gitflow-installer.sh | bash
```
