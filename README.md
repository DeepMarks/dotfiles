# dotfiles

This branch of the excellent [dotfiles](https://github.com/nickjj/dotfiles) by [nickjj](https://github.com/nickjj) extends the original environment that is made for web development in vim with a local python environment for data science. For convenience it includes an shell script that executes all installations / updates automatically. Once installed it sets the default shell to zsh. Note that the installation script should only be used in WSL 2, since it also changes files in the windows directories.

## Installation 

Before you start the installation, make sure that
- You have virtualization enabled in your bios (manufacturer specific)
- WSL is installed with WSL 2 enabled as default ([guide](https://docs.microsoft.com/windows/wsl/install-win10))and
- And Ubuntu 20.04 LTS is installed ([windows store link](https://www.microsoft.com/p/ubuntu-2004-lts/9n6svws3rx71?activetab=pivot:overviewtab))

#### 1. Install MS Windows Apps

These apps are needed on the windows side for the environment to work without any special configurations
- [Windows Terminal](https://www.microsoft.com/p/windows-terminal/9n0dx20hk701?activetab=pivot:overviewtab)
- [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Firefox](https://www.mozilla.org/firefox/new/)
- [SumatraPDF](https://www.sumatrapdfreader.org/download-free-pdf-viewer.html)

#### 2. Make Firewall Exceptions

Make firewall exceptions for VcXsrv. This can be done either by allowing all com for the app or by making exceptions for specific ports. ([risks](https://support.microsoft.com/windows/risks-of-allowing-apps-through-windows-defender-firewall-654559af-3f54-3dcf-349f-71ccd90bcc5c))

#### 3. Install Dotfiles

1. Open Ubuntu in Windows Terminal
2. Make sure that git is installed and clone this repo to your home directory
> ```sh
> sudo apt install git
> git clone https://github.com/romanrue/dotfiles ~/dotfiles
> ```
3. Make machine and user configurations (do this before you run the install script!)
> Change memory allocation for wsl in `c/Users/roman/.wslconfig` based on your systems memory

>  Change windows username in folder structure, that is
> ```sh
> mv ~/dotfiles/c/Users/roman/ ~/dotfiles/c/Users/<windows username>/
> ```

> Change github credentials in `.gitconfig.user`

> Source install script from dotfiles directory (you must navigate to the dotfiles directory every time you source it!)
> ```sh
> cd ~/dotfiles/
> ./installscript.sh
> ```

## Remarks

#### PATHS
To integrate the windows apps into the dotfiles workflow, linux must be able to detect their respective executables. Luckily WSL appends the windows paths to the linux ones. Therefore we only need to include the desired apps to the windows path. In the current setup the paths for
- firefox, standar location `C:\Program Files\Mozilla Firefox`
- SumatraPDF, standard location `C:\Users\<username>\AppData\Local\SumatraPDF`
were manually added.
If you do not want to extend your windows path variable include the absolute paths to the respective windows executable inside of `.local/bin/wslinks/`

#### Aliases do not work with GNU Make
Because GNU Make is only looking for executables one can find some simple executables inside of `.local/bin/wslinks/`. These scripts execute the respective windows executable and can also be called from any Makefile

#### You don't want to use firefox
If you prefer another browser, change the the firefox link in the `.vimrc` to your browser and add an alias or an executable to `.local/bin/wslinks/`

#### Introduction
If you want to learn more, I can really recommend the content provided by the original author.

## TODO

- Add/Iterate on Themes for QtConsole
- Add Themes for jupyter notebook
