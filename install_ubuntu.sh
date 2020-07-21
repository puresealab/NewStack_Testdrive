#!/bin/bash
# This is only to be used as a prep for the Pure Test Drive Environment
# Brian Kuebler 4/17/20

# Install necessary packages, only python2 installed

echo "#####################################"


# Install SDK

echo "####  Installing the Pure Storage SDK  ####"
pip3 install purestorage
pip3 install jmespath
pip3 install ansible
# Install the Pure Storage collection

# Ansible is being installed with PIP3, so we need to update the path for the users
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc

echo "#### Installing the Purestorage Ansible Collection  ####"

ansible-galaxy collection install purestorage.flasharray


echo "####  Making VIM feel right ####"

cat << 'EOF' >> ~/.vimrc
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
colo torte              " set colorscheme
syntax on               " syntax highlighing on
set expandtab           " tabs are spaces
set softtabstop=4       " number of spaces in tab when editing
set tabstop=4           " number of visual spaces per TAB
EOF



#systemctl restart multipathd
#/usr/sbin/multipath -r


# Save a second and create a mount point in /mnt - Actually, Ansible will create the mount point.
# mkdir /mnt/ansible-src

# Typing "ansible-playbook" everytime is a hassle...
echo "" >> ~/.bashrc
echo "alias ap='ansible-playbook'" >> ~/.bashrc
echo "alias P='cd ~/newstack_testdrive/ansible_playbooks'" >> ~/.bashrc
source ~/.bashrc


#generate an ssh key for local login:
echo "#### Generate SSH keys on local install ####"
ssh-keygen -t rsa -N '' -q -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#clone required repositories
echo "#### Clone kubespray repo and copy inventory in to repo ####"
git clone https://github.com/kubernetes-sigs/kubespray ~/kubespray
cp -rfv ~/newstack_testdrive/inventory/testdrive ~/kubespray/inventory/
cd ~/kubespray

# Install prereqs as we now have pip3
echo "#### Install kubespray prereqs ####"
pip3 install -r requirements.txt

# Install kubernetes
echo "#### Install kubernetes ####"
ansible-playbook -i inventory/testdrive/inventory.ini cluster.yml -b

# configure kubectl. needs to be updated as it only works
sudo cp /etc/kubernetes/admin.conf ~/.
sudo chown $(id -u):$(id -g) ~/admin.conf
echo 'export KUBECONFIG=$HOME/admin.conf' >> ~/.bashrc
at << 'EOF' >> ~/.bashrc
export KUBECONFIG=$HOME/admin.conf
source <(kubectl completion bash)
complete -F __start_kubectl k
alias kgp='kubectl get pods --all-namespaces'
alias kgv="kubectl get VolumeSnapShots"
EOF
source ~/.bashrc

#Install PSO
echo "#### Update helm repos and install PSO ####"
helm repo add pure https://purestorage.github.io/helm-charts
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
helm install pure-storage-driver pure/pure-csi --namespace default -f ~/newstack_testdrive/kubernetes_yaml/pso_values.yaml
