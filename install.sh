#!/bin/bash
# This is only to be used as a prep for the Pure Test Drive Environment
# Brian Kuebler 4/17/20

# Install necessary packages, only python2 installed

echo "#####################################"

APACKG=( epel-release python3 python3-pip centos-release-ansible-29 ansible vim python2-jmespath )


echo "####  Installing Python3 and Ansible  ####"

for pkg in "${APACKG[@]}";do
    if yum -q list installed "$pkg" > /dev/null 2>&1; then
        echo -e "$pkg is already installed"
    else
        yum install "$pkg" -y && echo "Successfully installed $pkg"
    fi
done



# Install SDK

echo "####  Installing the Pure Storage SDK  ####"
pip3 install purestorage
pip3 install jmespath
# Install the Pure Storage collection

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

# We need to change the hostname of this host. Note that it's "linux" on the FA
# and it's "Linux" on the host.

echo "#### Changing hostname ####"

echo "linux" > /etc/hostname
systemctl restart systemd-hostnamed
sleep 3

HNAME=$(hostname)

for lname in 'linux';do
    if [ "$HNAME" = "$lname" ]; then
        echo "Hostname is linux, matches FlashArray."
    else
        echo "Hostname still needs to be changed!"
    fi
done


#systemctl restart multipathd
#/usr/sbin/multipath -r

git config --global user.name "ccrow42"
git config --global user.email chris@ccrow.org

# Save a second and create a mount point in /mnt - Actually, Ansible will create the mount point.
# mkdir /mnt/ansible-src

# Typing "ansible-playbook" everytime is a hassle...
echo "" >> ~/.bashrc
echo "alias ap='ansible-playbook'" >> ~/.bashrc
echo "alias P='cd ~/ansibletest/Playbooks'" >> ~/.bashrc
source ~/.bashrc

#Disable SElinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && cat /etc/selinux/config
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux

# Should be able to remove this after 1.23 is released
mv ~/.ansible/collections/ansible_collections/purestorage/flasharray/plugins/modules/purefa_pod.py ~/purefa_pod.orig
cp ~/ansibletest/purefa_pod.py ~/.ansible/collections/ansible_collections/purestorage/flasharray/plugins/modules/

#generate an ssh key for local login:
ssh-keygen -t rsa -N '' -q -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#clone required repositories
git clone https://github.com/kubernetes-sigs/kubespray ~/kubespray
cp -rfv ~/newstack/kubetd/inventory/testdrive ~/kubespray/inventory/
cd ~/kubespray

# Install prereqs as we now have pip3
pip3 install -r requirements.txt

# Install kubernetes
ansible-playbook -i inventory/testdrive/inventory.ini cluster.yml -b

#Install PSO
helm repo add pure https://purestorage.github.io/helm-charts
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
helm install pure-storage-driver pure/pure-csi --namespace default -f ~/newstack/kubetd/pso_values.yaml
