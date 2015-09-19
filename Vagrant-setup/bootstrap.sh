#!/usr/bin/env bash
PROVISIONED_ON=/var/vagrant_provisioned_at

echo "Provisioning begins for Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-55-generic i686) box..."

#Download latest index of available packages
apt-get update

apt-get -y install tree unzip vim supervisor git golang

echo "______________"
echo "Installing go appengine sdk now"
echo "______________"
GAE_GO_SDK_FILE='go_appengine_sdk_linux_386-1.9.26.zip'
GAE_GO_SDK_URL=https://storage.googleapis.com/appengine-sdks/featured/$GAE_GO_SDK_FILE

GAE_BASE=/opt
GAE=go_appengine
GAE_DIR=$GAE_BASE/$GAE

cd $GAE_BASE
rm -rf $GAE_DIR
wget --quiet $GAE_GO_SDK_URL -O temp.zip && unzip temp.zip -d $GAE_BASE/; rm temp.zip

cat >>/etc/profile.d/$GAE.sh<<EOL
PATH=\$PATH:$GAE_DIR
EOL

echo "______________"
echo "Installation over for $GAE_GO_SDK_FILE"
echo "______________"

# Update package list and upgrade all packages
apt-get -y upgrade

cat >> /home/vagrant/.bashrc <<EOL
cd /vagrant
EOL

cat >> /home/vagrant/.pam_environment <<EOL
PYTHONPATH=/vagrant
GOPATH=/home/vagrant/gopath
EOL
EXPORT GOPATH=/home/vagrant/gopath
goapp get github.com/go-martini/martini

cat >> /home/vagrant/.bash_aliases <<EOL
alias ..='cd ..'
alias g='sudo vim'
alias al='vim ~/.bash_aliases'
alias re='source ~/.bash_aliases'
alias atdtime='sudo timedatectl set-timezone Asia/Kolkata'
findFile(){
find . -name "*$1*"
}
alias ff=findFile

EOL

cat >/home/vagrant/.vimrc<<EOL
set nu
map \\\\ :q!<CR>
map <leader>v :e /home/vagarant/.vimrc<CR>
map <space> /
map ,re :source ~/.vimrc<CR>
imap <tab> <C-X><C-P>
map j gj
map k gk
noremap - gT
noremap <c-space> gt
noremap <leader>t :Tex<CR>
noremap <C-s> :w<CR>
colorscheme slate
EOL


cat > /etc/supervisor/conf.d/goserve_sdatcrm <<EOL
[program:vagrant_adaptwater]
command=cd /vagrant && goapp serve --host ::
stdout_logfile=/vagrant/vagrantlogs.log
autostart=true
redirect_stderr=true
EOL


supervisorctl reread
supervisorctl update


# Tag the provision time:
date > "$PROVISIONED_ON"
