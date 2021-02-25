#!/bin/bash
sudo apt update && sudo apt install -y \
	curl \
	git \
	gnupg \
	htop \
	jq \
	pass \
	pwgen \
	python3-pip \
	ripgrep \
	rsync \
	shellcheck \
	tmux \
	unzip \
	vim-gtk \
	tk-dev \
	libsqlite3-dev \
	libbz2-dev

# Create symlinks to various dotfiles. If you didn't clone it to ~/dotfiles
# then adjust the ln -s symlink source (left side) to where you cloned it.
mkdir -p "${HOME}/.local/bin" && mkdir -p "${HOME}/.vim/spell"
SYMLINKFILES=( \
	"/.aliases" \
	"/.bashrc" \
	"/.gemrc" \
	"/.gitconfig" \
	"/.gitconfig.user" \
	"/.p10k.zsh" \
	"/.profile" \
	"/.tmux.conf" \
	"/.vimrc" \
	"/.zshrc" \
	"/.vim/spell/en.utf-8.add" \
	"/.local/bin/set-theme" \
)
for i in "${SYMLINKFILES[@]}"
do
	test -f "${PWD}${i}" && ln -sf "${PWD}${i}" "${HOME}${i}" || echo "${PWD}${i} not found"
done

# NOTE: This one is WSL 1 / 2 specific. Don't do it on native Linux / macOS.
sudo ln -sf ~/dotfiles/etc/wsl.conf /etc/wsl.conf

# Copy Windows configuration files for WSL
WINFILENAMES=( \
	".wslconfig" \
	"config.xlaunch" \
	"settings.json" \
	"SumatraPDF-settings.txt" \
)
for i in "${WINFILENAMES[@]}"
do
	FILE=$(find . -name "$i";)
	if [ -d $(dirname "${FILE#.}") ]
	then
		cp -f "${PWD}${FILE#.}" "${FILE#.}"
	elif [ -d $(dirname "/mnt${FILE#.}") ]
	then
		cp -f "${PWD}${FILE#.}" "/mnt${FILE#.}"
	fi
done

# Install Plug (Vim plugin manager).
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install TPM (Tmux plugin manager).
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install FZF (fuzzy finder on the terminal and used by a Vim plugin).
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all

# Install ASDF (version manager which I use for non-Dockerized apps).
git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf

source ${HOME}/.bashrc

# Install Node through ASDF. Even if you don't use Node / Webpack / etc., there
# is one Vim plugin (Markdown Preview) that requires Node and Yarn.
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add yarn
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs latest
asdf global nodejs $(asdf latest nodjs)
asdf install yarn latest
asdf global yarn $(asdf latest yarn)

# Install system dependencies for Ruby on Debian / Ubuntu.
#
# Not using Debian or Ubuntu? Here's alternatives for macOS and other Linux distros:
#   https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
sudo apt install -y autoconf bison build-essential libssl-dev libyaml-dev \
	libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev

# Install Ruby through ASDF.
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby latest
asdf global ruby $(asdf latest ruby)

# Install Ansible.
asdf plugin remove python
pip3 install --user ansible

# Install Python
asdf plugin add python
asdf install python 3.8.5
asdf install python latest
asdf global python 3.8.5
python -m pip install --upgrade \
	pip \
	virtualenv
asdf global python $(asdf latest python)
python -m pip install --upgrade \
	pip \
	virtualenv

# Install AWS CLI v2.
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip && sudo A | ./aws/install && rm awscliv2.zip

# Install Terraform.
curl "https://releases.hashicorp.com/terraform/0.13.2/terraform_0.13.2_linux_amd64.zip" -o "terraform.zip" \
	&& unzip terraform.zip && chmod +x terraform \
	&& mv terraform ~/.local/bin && rm terraform.zip

# Setup vim
vim +'silent! so ~/.vimrc | PlugInstall' +qa

# Setup tmux
tmux new-session -d -s tmux_setup '`I'

# Install zsh with oh-my-zsh and plugins
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
PLUGIN_SRCS=( \
	"https://github.com/zsh-users/zsh-autosuggestions.git" \
	"https://github.com/zsh-users/zsh-syntax-highlighting.git" \
	"https://github.com/romkatv/powerlevel10k.git" \
)
PLUGIN_DESTS=( \
	"${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" \
	"${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" \
	"${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k" \
)
PLUGIN_PREM=( "" "" "--depth=1" )
for i in "${!PLUGIN_SRCS[@]}"
do
	test -d ${PLUGIN_DESTS[i]} \
		&& git --git-dir=${PLUGIN_DESTS[i]}/.git pull \
		|| git clone ${PLUGIN_PREM[i]} ${PLUGIN_SRCS[i]} ${PLUGIN_DESTS[i]}
done

# Install powerlevel10k with preconfigured settings
# Copy custom bash scripts that open ms windows software without exe extension
WSLINK_PATH="${HOME}/.local/bin/wslinks"
WSLINKFILES=($(find "${PWD}${WSLINK_PATH#${HOME}}" -maxdepth 1 -not -type d | tr ";" "\n"))
mkdir -p ${WSLINK_PATH}
for FILE in "${WSLINKFILES[@]}"
do
	ln -sf "${FILE}" "${HOME}${FILE#${PWD}}"
done

# Install texlive
sudo apt install -y texlive-full

# Install  markdown-preview for vim
vim +'silent! mkdp#util#install()' +qa
mkdir -p "${HOME}/.local/lib/markdown-preview-css/github/"
ln -sf "${PWD}/.local/lib/markdown-preview-css/github/github-markdown.css" "${HOME}/.local/lib/markdown-preview-css/github/"

# Creare Python-Environment with Jupyter QtConsole output
asdf global python 3.8.5
VENVSPATH="${HOME}/.venvs/"
mkdir -p "${VENVSPATH}"
ln -sf "${PWD}${VENVSPATH#${HOME}}vimJupy_requirements.txt" "${VENVSPATH}"
python -m virtualenv "${VENVSPATH}vimJupy"
source "${VENVSPATH}vimJupy/bin/activate"
python -m pip install --upgrade -r "${VENVSPATH}vimJupy_requirements.txt"

# Customize QtConsole
mkdir -p "${HOME}/.jupyter/custom/"
ln -sf "${PWD}/.jupyter/jupyter_qtconsole_config.py" "${HOME}/.jupyter/"
git clone "https://github.com/romanrue/qtc-color-themes.git"  "${HOME}/.jupyter/custom/qtc-color-themes"
python -m pip install -e "${HOME}/.jupyter/custom/qtc-color-themes"

deactivate
asdf global python $(asdf latest python)
