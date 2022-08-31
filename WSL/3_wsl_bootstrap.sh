#!/bin/bash

### Check Ubuntu version (if using Ubuntu)
OS_NAME=$(cat /etc/*-release | grep PRETTY_NAME= | awk '{ print substr( $0, 14, length($0)-14 ) }')

if [[ $(echo $OS_NAME | awk '{ print substr( $0, 0, 6 ) }') == "Ubuntu" ]]; then
	if [[ $(echo $OS_NAME | awk '{ print substr( $0, 0, 12 ) }') != "Ubuntu 18.04" ]]; then
		echo "$(tput setaf 1)[WARNING] This script was built for 'Ubuntu 18.04' whereas you are currently using '${OS_NAME}' $(tput setaf 7)"
		echo "$(tput setaf 1)[WARNING] The installation will continue, however errors may arise $(tput setaf 7)"
		echo ""
		while [[ $ready_response != "ready" ]] ; do
			read -p "Type 'ready' once you are ready to move on: " ready_response
		done
		ready_response=""
		clear
	fi
	OS_NAME="Ubuntu"
fi


### Update and install OS packages
if [[ $OS_NAME == "Ubuntu" ]]; then
	# Ubuntu (apt package manager)
	echo "$(tput setaf 2)[INFO] Updating core packages $(tput setaf 7)"
	sudo apt update
	sudo apt upgrade -y
	sudo apt autoremove -y
	sudo apt autoclean -y
	echo "$(tput setaf 2)[INFO] Installing required packages $(tput setaf 7)"
	sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev python3-pip
	
	# pyenv
	git clone https://github.com/pyenv/pyenv.git ~/.pyenv
	cd ~/.pyenv && src/configure && make -C src
	echo '' >> ~/.profile
	echo '# Setup pyenv & virtualenv' >> ~/.profile
	echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
	echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
	echo 'eval "$(pyenv init -)"' >> ~/.profile
	source ~/.profile
	
	echo "" >> ~/.bashrc
	echo "# Setup pyenv & virtualenv" >> ~/.bashrc
	echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
	echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
	echo 'eval "$(pyenv init -)"' >> ~/.bashrc
	source ~/.bashrc

	# yarn
	npm install --global yarn
	
elif [[ $OS_NAME == "openSUSE Tumbleweed" ]]; then
	# openSUSE (Zypper package manager)
	echo "$(tput setaf 2)[INFO] Updating core packages $(tput setaf 7)"
	sudo zypper --non-interactive refresh
	sudo zypper --non-interactive update
	echo "$(tput setaf 2)[INFO] Installing required packages $(tput setaf 7)"
	sudo zypper --non-interactive install git gcc automake bzip2 libbz2-devel xz xz-devel openssl-devel ncurses-devel readline-devel zlib-devel tk-devel libffi-devel sqlite3-devel make bash-completion python python3-pip pyenv npm yarn

else
	# unsupported distribution
	echo "$(tput setaf 1)[ERROR] This script only supports 'Ubuntu' and 'openSUSE Tumbleweed' at this time $(tput setaf 7)"
	exit 0
fi


### Install additional packages
pip3 install awsume awscli boto3
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv


### Configure bash
# pyenv and pyenv-virtualenv
if [[ $OS_NAME == "Ubuntu" ]]; then
	echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.profile
	source ~/.profile
	echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
	
elif [[ $OS_NAME == "openSUSE Tumbleweed" ]]; then
	echo "" >> ~/.bashrc
	echo "# Setup pyenv & virtualenv" >> ~/.bashrc
	echo 'eval "$(pyenv init -)"' >> ~/.bashrc
	echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
fi
echo "" >> ~/.bashrc

# bash auto-completion
echo "# Bash auto-completion" >> ~/.bashrc
echo "if [ -f /etc/bash_completion ]; then" >> ~/.bashrc
echo "  . /etc/bash_completion" >> ~/.bashrc
echo "fi" >> ~/.bashrc
echo "" >> ~/.bashrc

# display current git branch name in the prompt
echo "# Git branch in prompt" >> ~/.bashrc
echo "parse_git_branch() {" >> ~/.bashrc
echo "    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'" >> ~/.bashrc
echo "}" >> ~/.bashrc
echo 'export PS1="$\[\033[32m\]\u@\h \[\033[00m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "' >> ~/.bashrc
source ~/.bashrc


### Configure GitHub SSH
# Set gitconfig
clear
echo "$(tput setaf 2)[INFO] Please input your GitHub name and email when prompted"
read -p "$(tput setaf 2)Username: $(tput setaf 7)" git_user
read -p "$(tput setaf 2)Email: $(tput setaf 7)" git_email
git config --global user.name ${git_user}
git config --global user.email ${git_email}

# Generate SSH key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C ${git_email} >/dev/null
eval "$(ssh-agent -s)" >/dev/null
ssh-add ~/.ssh/id_ed25519 2>/dev/null
clear
echo "$(tput setaf 2)[INFO] Please add the following SSH key to your GitHub account"
echo "$(tput setaf 3)You can do this by opening github.com in your browser of choice and navigating to:"
echo "Settings > SSH and GPG keys > New SSH key"
echo "$(tput setaf 3)Once the key has been added, please enable SSO for your new key"
echo ""
echo "$(tput setaf 2)[KEY] $(tput setaf 7)"
cat ~/.ssh/id_ed25519.pub
echo ""
while [[ $ready_response != "ready" ]] ; do
	read -p "Type 'ready' once you are ready to move on: " ready_response
done
ready_response=""


### Configure AWS
mkdir -p ~/.aws
echo "[default]" | sudo tee ~/.aws/config >/dev/null
echo "region=eu-west-1" | sudo tee -a ~/.aws/config >/dev/null
echo "output=json" | sudo tee -a ~/.aws/config >/dev/null
# the rest of this section has been redacted...


# Completion notification
clear
if [[ $OS_NAME == "Ubuntu" ]]; then
	echo "$(tput setaf 2)[INFO] Your WSL environment is nearly set up $(tput setaf 7)"
	echo "$(tput setaf 2)[INFO] Please restart WSL to complete the installation $(tput setaf 7)"
elif [[ $OS_NAME == "openSUSE Tumbleweed" ]]; then
	echo "$(tput setaf 2)[INFO] Your WSL environment is all set up and ready to go $(tput setaf 7)"
fi
echo ""
echo ""