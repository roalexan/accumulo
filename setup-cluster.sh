#!/bin/bash

# Install Python 3.6 and create a virtual environment

cd ~

sudo yum install -y epel-release
sudo yum install -y python36 python36-devel python36-setuptools
sudo python36 /usr/lib/python3.6/site-packages/easy_install.py pip
python3.6 -m venv env

# Install Ansible and VMSS (virtual machine scale set) patch

#yum check-update
#yum install -y gcc libffi-devel python-devel openssl-devel
#yum install -y python-pip python-wheel
#pip install ansible[azure]
#yum -y install git
#git clone https://github.com/ansible/ansible
#cp ansible/lib/ansible/modules/cloud/azure/azure_rm_virtualmachinescaleset.py env/lib/python3.6/site-packages/ansible/modules/cloud/azure/
