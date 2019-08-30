#!/bin/bash
cd ~

echo "Read the options" > setup-cluster.log
TEMP=`getopt -o a:p:t:s: --long app-id:,password:,tenant-id: -- "$@"`
eval set -- "$TEMP"

echo "Extract options and their arguments into variables" >> setup-cluster.log
while true ; do
    case "$1" in
        -a|--app-id)
            appId=$2 ; shift 2 ;;
        -p|--password)
            password=$2 ; shift 2;;
        -t|--tenant-id)
            tenantId=$2 ; shift 2;;
        -s|--subscription-id)
            subscriptionId=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "ERROR: Unable to get variables from arguments" ; exit 1 ;;
    esac
done

echo "Install Python 3.6 and create a virtual environment" >> setup-cluster.log
#sudo yum install -y epel-release
#sudo yum install -y python36 python36-devel python36-setuptools
#sudo python36 /usr/lib/python3.6/site-packages/easy_install.py pip
#python3.6 -m venv ~/env
#source ~/env/bin/activate

echo "Install Ansible and VMSS (virtual machine scale set) patch" >> setup-cluster.log
#sudo yum check-update
#sudo yum install -y gcc libffi-devel python-devel openssl-devel
#sudo yum install -y python-pip python-wheel
#pip install ansible[azure]
#sudo yum -y install git
#git clone https://github.com/ansible/ansible
#cp ansible/lib/ansible/modules/cloud/azure/azure_rm_virtualmachinescaleset.py env/lib/python3.6/site-packages/ansible/modules/cloud/azure/

echo "Download the Magna Carta repo zip" >> setup-cluster.log
#ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
#mkdir ~/fluo-muchos
#wget https://roalexan.blob.core.windows.net/accumulo/fluo-muchos.zip --output-document ~/fluo-muchos/fluo-muchos.zip
#unzip ~/fluo-muchos/fluo-muchos.zip -d ~/fluo-muchos

echo "Setup agent forwarding" >> setup-cluster.log
#export ANSIBLE_HOST_KEY_CHECKING=False
#export ANSIBLE_LOG_PATH=~/play.log
#eval $(ssh-agent -s)
#ssh-add ~/.ssh/id_rsa

echo "Install Azure CLI" >> setup-cluster.log
#sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
#sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
#sudo yum install -y azure-cli
#sed -i '/^PYTHONPATH=/c\PYTHONPATH=/usr/lib64/az/lib/python2.7/site-packages python2 -sm azure.cli "$@"' $(which az)
#az login --service-principal --username "$APP_ID" --password "$PASSWORD" --tenant "$TENANT_ID"
#az account set --subscription "$subscriptionId"

echo "Update muchos.props" >> setup-cluster.log
/bin/cp ~/fluo-muchos/conf/muchos.props.example ~/fluo-muchos/conf/muchos.props
sed -i '/^cluster_type =/c\cluster_type = azure' ~/fluo-muchos/conf/muchos.props
sed -i '/^cluster_user =/c\cluster_user = rba1' ~/fluo-muchos/conf/muchos.props
sed -i '/^hadoop_version =/c\hadoop_version = 3.2.0' ~/fluo-muchos/conf/muchos.props
sed -i '/^spark_version =/c\spark_version = 2.4.3' ~/fluo-muchos/conf/muchos.props
sed -i '/^accumulo_version =/c\accumulo_version = 2.0.0' ~/fluo-muchos/conf/muchos.props
sed -i '/^nameservice_id =/c\nameservice_id = rbaaccucluster' ~/fluo-muchos/conf/muchos.props
sed -i '/^profile=/c\profile=perf-small' ~/fluo-muchos/conf/muchos.props
