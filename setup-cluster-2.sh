#!/bin/bash
cd ~
rm --force ./setup-cluster.log
exec > >(tee --append ./setup-cluster.log)
exec 2>&1

date
echo "Read the options"
TEMP=`getopt -o s:g:n:v:d:b:l:w:x:y:z --long subscription-id:,resource-group:,num-nodes:,vm-sku:,num-disks:,disk-size-gb:,location:,vnet:,vnet-cidr:,subnet:,subnet-cidr: -- "$@"`
eval set -- "$TEMP"

echo "Extract options and their arguments into variables"
while true ; do
    case "$1" in
        -s|--subscription-id)
            subscriptionId=$2 ; shift 2;;
        -g|--resource-group)
            resourceGroup=$2 ; shift 2;;
        -n|--num-nodes)
            numNodes=$2 ; shift 2;;
        -v|--vm-sku)
            vmSku=$2 ; shift 2;;
        -d|--num-disks)
            numDisks=$2 ; shift 2;;
        -b|--disk-size-gb)
            diskSizeGb=$2 ; shift 2;;
        -l|--location)
            location=$2 ; shift 2;;            
        -w|--vnet)
            vnet=$2 ; shift 2;;
        -x|--vnet-cidr)
            vnetCidr=$2 ; shift 2;;
        -y|--subnet)
            subnet=$2 ; shift 2;;
        -z|--subnet-cidr)
            subnetCidr=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "ERROR: Unable to get variables from arguments" ; exit 1 ;;
    esac
done
if [ -z "$subscriptionId" ]
then
    echo "Missing required argument: -s | subscription-id"
    exit 1
fi
if [ -z "$resourceGroup" ]
then
    echo "Missing required argument: -g | resource-group"
    exit 1
fi
if [ -z "$numNodes" ]
then
    echo "Missing required argument: -n | num-nodes"
    exit 1
fi
if [ -z "$vmSku" ]
then
    echo "Missing required argument: -v | vm-sku"
    exit 1
fi
if [ -z "$numDisks" ]
then
    echo "Missing required argument: -d | num-disks"
    exit 1
fi
if [ -z "$diskSizeGb" ]
then
    echo "Missing required argument: -b | disk-size-gb"
    exit 1
fi
if [ -z "$location" ]
then
    echo "Missing required argument: -l | location"
    exit 1
fi
if [ -z "$vnet" ]
then
    echo "Missing required argument: -w | vnet"
    exit 1
fi
if [ -z "$vnetCidr" ]
then
    echo "Missing required argument: -x | vnet-cidr"
    exit 1
fi
if [ -z "$subnet" ]
then
    echo "Missing required argument: -y | subnet"
    exit 1
fi
if [ -z "$subnetCidr" ]
then
    echo "Missing required argument: -z | subnet-cidr"
    exit 1
fi

echo "Install Python 3.6 and create a virtual environment"
sudo yum install -y epel-release
sudo yum install -y python36 python36-devel python36-setuptools
sudo python36 /usr/lib/python3.6/site-packages/easy_install.py pip
python3.6 -m venv ~/env
source ~/env/bin/activate

echo "Install Ansible and VMSS (virtual machine scale set) patch"
sudo yum check-update
sudo yum install -y gcc libffi-devel python-devel openssl-devel
sudo yum install -y python-pip python-wheel
pip install ansible[azure]
sudo yum -y install git
git clone https://github.com/ansible/ansible
cp ansible/lib/ansible/modules/cloud/azure/azure_rm_virtualmachinescaleset.py env/lib/python3.6/site-packages/ansible/modules/cloud/azure/

echo "Download the Magna Carta repo zip"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
mkdir ~/fluo-muchos
wget https://roalexan.blob.core.windows.net/accumulo/fluo-muchos.zip --output-document ~/fluo-muchos/fluo-muchos.zip
unzip ~/fluo-muchos/fluo-muchos.zip -d ~/fluo-muchos

echo "Install Azure CLI"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
sudo yum install -y azure-cli
sed -i '/^PYTHONPATH=/c\PYTHONPATH=/usr/lib64/az/lib/python2.7/site-packages python2 -sm azure.cli "$@"' $(which az)

echo "Update muchos.props"
nameservice_id=rbaaccucluster
/bin/cp ~/fluo-muchos/conf/muchos.props.example ~/fluo-muchos/conf/muchos.props
sed -i "/^cluster_type =/c\cluster_type = azure" ~/fluo-muchos/conf/muchos.props
sed -i "/^cluster_user =/c\cluster_user = rba1" ~/fluo-muchos/conf/muchos.props
sed -i "/^hadoop_version =/c\hadoop_version = 3.2.0" ~/fluo-muchos/conf/muchos.props
sed -i "/^spark_version =/c\spark_version = 2.4.3" ~/fluo-muchos/conf/muchos.props
sed -i "/^accumulo_version =/c\accumulo_version = 2.0.0" ~/fluo-muchos/conf/muchos.props
sed -i "/^nameservice_id =/c\nameservice_id = $nameservice_id" ~/fluo-muchos/conf/muchos.props
sed -i "/^profile=/c\profile=perf-small" ~/fluo-muchos/conf/muchos.props
sed -i "/^resource_group =/c\resource_group = $resourceGroup" ~/fluo-muchos/conf/muchos.props
sed -i "/^vnet =/c\vnet = $vnet" ~/fluo-muchos/conf/muchos.props
sed -i "/^vnet_cidr =/c\vnet_cidr = $vnetCidr" ~/fluo-muchos/conf/muchos.props
sed -i "/^subnet =/c\subnet = $subnet" ~/fluo-muchos/conf/muchos.props
sed -i "/^subnet_cidr =/c\subnet_cidr = $subnetCidr" ~/fluo-muchos/conf/muchos.props
sed -i "/^numnodes =/c\numnodes = $numNodes" ~/fluo-muchos/conf/muchos.props
sed -i "/^vm_sku =/c\vm_sku = $vmSku" ~/fluo-muchos/conf/muchos.props
sed -i "/^location =/c\location = $location" ~/fluo-muchos/conf/muchos.props
sed -i "/^numdisks =/c\numdisks = $numDisks" ~/fluo-muchos/conf/muchos.props
sed -i "/^disk_size_gb =/c\disk_size_gb = $diskSizeGb" ~/fluo-muchos/conf/muchos.props
