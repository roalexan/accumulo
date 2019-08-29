#!/bin/bash

echo "1" > ~/t.t

echo $1 >> ~/t.t
echo $2 >> ~/t.t
echo $3 >> ~/t.t
echo $4 >> ~/t.t

echo "2" >> ~/t.t
APP_ID="$1"
echo "3" >> ~/t.t
PASSWORD="$2"
echo "4" >> ~/t.t
TENANT_ID="$3"
echo "5" >> ~/t.t
SUBSCRIPTION_ID="$4"
echo "6" >> ~/t.t

echo "$APP_ID" >> ~/t.t
echo "7" >> ~/t.t
echo "$PASSWORD" >> ~/t.t
echo "8" >> ~/t.t
echo "$TENANT_ID" >> ~/t.t
echo "9" >> ~/t.t
echo "$SUBSCRIPTION_ID" >> ~/t.t
echo "10" >> ~/t.t

cd ~

# Install Python 3.6 and create a virtual environment

#sudo yum install -y epel-release
#sudo yum install -y python36 python36-devel python36-setuptools
#sudo python36 /usr/lib/python3.6/site-packages/easy_install.py pip
#python3.6 -m venv ~/env
#source ~/env/bin/activate

# Install Ansible and VMSS (virtual machine scale set) patch

#sudo yum check-update
#sudo yum install -y gcc libffi-devel python-devel openssl-devel
#sudo yum install -y python-pip python-wheel
#pip install ansible[azure]
#sudo yum -y install git
#git clone https://github.com/ansible/ansible
#cp ansible/lib/ansible/modules/cloud/azure/azure_rm_virtualmachinescaleset.py env/lib/python3.6/site-packages/ansible/modules/cloud/azure/

# Download the Magna Carta repo zip

#ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
#mkdir ~/fluo-muchos
#wget https://roalexan.blob.core.windows.net/accumulo/fluo-muchos.zip --output-document ~/fluo-muchos/fluo-muchos.zip
#unzip ~/fluo-muchos/fluo-muchos.zip -d ~/fluo-muchos

# Setup agent forwarding

#export ANSIBLE_HOST_KEY_CHECKING=False
#export ANSIBLE_LOG_PATH=~/play.log
#eval $(ssh-agent -s)
#ssh-add ~/.ssh/id_rsa

# Install Azure CLI

#sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
#sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
#sudo yum install -y azure-cli
#sed -i '/^PYTHONPATH=/c\PYTHONPATH=/usr/lib64/az/lib/python2.7/site-packages python2 -sm azure.cli "$@"' $(which az)
#az login --service-principal --username $APP_ID --password $PASSWORD --tenant $TENANT_ID
#az account set --subscription $SUBSCRIPTION_ID

# Update muchos.props

#/bin/cp ~/fluo-muchos/conf/muchos.props.example ~/fluo-muchos/conf/muchos.props
#touch ~/t.t
#echo $APP_ID > ~/t.t
#echo $PASSWORD >> ~/t.t
#echo $TENANT_ID >> ~/t.t
#echo $SUBSCRIPTION_ID >> ~/t.t
