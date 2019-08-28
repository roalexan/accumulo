#!/bin/bash

cd ~

# Install Python 3.6 and create a virtual environment

sudo yum install -y epel-release
sudo yum install -y python36 python36-devel python36-setuptools
sudo python36 /usr/lib/python3.6/site-packages/easy_install.py pip
python3.6 -m venv ~/env
source ~/env/bin/activate

# Install Ansible and VMSS (virtual machine scale set) patch

sudo yum check-update
sudo yum install -y gcc libffi-devel python-devel openssl-devel
sudo yum install -y python-pip python-wheel
pip install ansible[azure]
sudo yum -y install git
git clone https://github.com/ansible/ansible
cp ansible/lib/ansible/modules/cloud/azure/azure_rm_virtualmachinescaleset.py env/lib/python3.6/site-packages/ansible/modules/cloud/azure/

# Download the Magna Carta repo zip

ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
mkdir ~/fluo-muchos
wget https://roalexan.blob.core.windows.net/accumulo/fluo-muchos.zip --output-document ~/fluo-muchos/fluo-muchos.zip
unzip ~/fluo-muchos/fluo-muchos.zip -d ~/fluo-muchos

# Setup agent forwarding

export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_LOG_PATH=~/play.log
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

# Install Azure CLI

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
sudo yum install -y azure-cli
sed -i '/^PYTHONPATH=/c\PYTHONPATH=/usr/lib64/az/lib/python2.7/site-packages python2 -sm azure.cli "$@"' $(which az)
