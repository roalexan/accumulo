#!/bin/bash
cd ~
rm --force ./setup-cluster.log
exec > >(tee --append ./setup-cluster.log)
exec 2>&1

date
echo "Read the options"
TEMP=`getopt -o a:p:t:s:g --long app-id:,password:,tenant-id:,subscription-id:,resource-group: -- "$@"`
eval set -- "$TEMP"

echo "Extract options and their arguments into variables"
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
        -g|--resource-group)
            resourceGroup=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "ERROR: Unable to get variables from arguments" ; exit 1 ;;
    esac
done
if [ -z "$appId" ]
then
    echo "Missing required argument: -a | app-id"
    exit 1
fi
if [ -z "$password" ]
then
    echo "Missing required argument: -p | password"
    exit 1
fi
if [ -z "$tenantId" ]
then
    echo "Missing required argument: -t | tenant-id"
    exit 1
fi
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

echo "Install Python 3.6 and create a virtual environment"
#sudo yum install -y epel-release
#sudo yum install -y python36 python36-devel python36-setuptools
#sudo python36 /usr/lib/python3.6/site-packages/easy_install.py pip
#python3.6 -m venv ~/env
source ~/env/bin/activate

echo "Install Ansible and VMSS (virtual machine scale set) patch"
#sudo yum check-update
#sudo yum install -y gcc libffi-devel python-devel openssl-devel
#sudo yum install -y python-pip python-wheel
#pip install ansible[azure]
#sudo yum -y install git
#git clone https://github.com/ansible/ansible
#cp ansible/lib/ansible/modules/cloud/azure/azure_rm_virtualmachinescaleset.py env/lib/python3.6/site-packages/ansible/modules/cloud/azure/

echo "Download the Magna Carta repo zip"
#ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
#mkdir ~/fluo-muchos
#wget https://roalexan.blob.core.windows.net/accumulo/fluo-muchos.zip --output-document ~/fluo-muchos/fluo-muchos.zip
#unzip ~/fluo-muchos/fluo-muchos.zip -d ~/fluo-muchos

echo "Setup agent forwarding"
#export ANSIBLE_HOST_KEY_CHECKING=False
#export ANSIBLE_LOG_PATH=~/play.log
#eval $(ssh-agent -s)
#ssh-add ~/.ssh/id_rsa

echo "Install Azure CLI"
#sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
#sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
#sudo yum install -y azure-cli
#sed -i '/^PYTHONPATH=/c\PYTHONPATH=/usr/lib64/az/lib/python2.7/site-packages python2 -sm azure.cli "$@"' $(which az)
#az login --service-principal --username "$APP_ID" --password "$PASSWORD" --tenant "$TENANT_ID"
#az account set --subscription "$subscriptionId"

nameservice_id=rbaaccucluster

echo "Update muchos.props"
#/bin/cp ~/fluo-muchos/conf/muchos.props.example ~/fluo-muchos/conf/muchos.props
#sed -i '/^cluster_type =/c\cluster_type = azure' ~/fluo-muchos/conf/muchos.props
#sed -i '/^cluster_user =/c\cluster_user = rba1' ~/fluo-muchos/conf/muchos.props
#sed -i '/^hadoop_version =/c\hadoop_version = 3.2.0' ~/fluo-muchos/conf/muchos.props
#sed -i '/^spark_version =/c\spark_version = 2.4.3' ~/fluo-muchos/conf/muchos.props
#sed -i '/^accumulo_version =/c\accumulo_version = 2.0.0' ~/fluo-muchos/conf/muchos.props
#sed -i '/^nameservice_id =/c\nameservice_id = rbaaccucluster' ~/fluo-muchos/conf/muchos.props
#sed -i '/^profile=/c\profile=perf-small' ~/fluo-muchos/conf/muchos.props
#sed -i "/^resource_group =/c\resource_group = $resourceGroup" ~/fluo-muchos/conf/muchos.props

vnet=$(az network vnet list --subscription $subscriptionId --resource-group $resourceGroup --query '[0].name' | cut -d \" -f2)
sed -i "/^vnet =/c\vnet = $vnet" ~/fluo-muchos/conf/muchos.props

vnetCidr=$(az network vnet list --subscription $subscriptionId --resource-group $resourceGroup --query '[0].addressSpace.addressPrefixes[0]' | cut -d \" -f2)
sed -i "/^vnet_cidr =/c\vnet_cidr = $vnetCidr" ~/fluo-muchos/conf/muchos.props

subnet=$(az network vnet list --subscription $subscriptionId --resource-group $resourceGroup --query '[0].subnets[0].name' | cut -d \" -f2)
sed -i "/^subnet =/c\subnet = $subnet" ~/fluo-muchos/conf/muchos.props

subnetCidr=$(az network vnet list --subscription $subscriptionId --resource-group $resourceGroup --query '[0].subnets[0].addressPrefix' | cut -d \" -f2)
sed -i "/^subnet_cidr =/c\subnet_cidr = $subnetCidr" ~/fluo-muchos/conf/muchos.props

numnodes="8"
sed -i "/^numnodes =/c\numnodes = $numnodes" ~/fluo-muchos/conf/muchos.props

vm_sku="Standard_D8s_v3"
sed -i "/^vm_sku =/c\vm_sku = $vm_sku" ~/fluo-muchos/conf/muchos.props

location="eastus"
sed -i "/^location =/c\location = $location" ~/fluo-muchos/conf/muchos.props

cd ~/fluo-muchos/bin
chmod +x ./muchos
./muchos launch --cluster $nameservice_id

sed -i "s/zkfc/zkfc,spark/" ~/fluo-muchos/conf/muchos.props
chmod +x ./ansible/scripts/install_ansible.sh
./muchos setup --cluster $nameservice_id

	#az network vnet list --subscription 6187b663-b744-4d24-8226-7e66525baf8f --resource-group rbaAccumulo7-rg --query '[0].{Name:name}.Name'
	#vnet="$(az network vnet list --subscription 6187b663-b744-4d24-8226-7e66525baf8f --resource-group rbaAccumulo7-rg --query '[0].{Name:name}.Name')"
	#vnet=$(az network vnet list --subscription 6187b663-b744-4d24-8226-7e66525baf8f --resource-group rbaAccumulo7-rg --query '[0].{Name:name}.Name' | cut -d \" -f2)
	
	#az network vnet list --subscription 6187b663-b744-4d24-8226-7e66525baf8f --resource-group rbaAccumulo7-rg --query '[0].{AddressSpace:addressSpace.addressPrefixes[0]}.AddressSpace'
	#vnetAddressSpace=$(az network vnet list --subscription 6187b663-b744-4d24-8226-7e66525baf8f --resource-group rbaAccumulo7-rg --query '[0].{AddressSpace:addressSpace.addressPrefixes[0]}.AddressSpace' | cut -d \" -f2)
	
	#subnet=$(az network vnet list --subscription 6187b663-b744-4d24-8226-7e66525baf8f --resource-group rbaAccumulo7-rg --query '[0].subnets[0].name' | cut -d \" -f2)
	
	#az network vnet list --subscription 6187b663-b744-4d24-8226-7e66525baf8f --resource-group rbaAccumulo7-rg --query '[0].subnets[0].addressPrefix'
	
	#[
	#  {
	#	"addressSpace": {
	#	  "addressPrefixes": [
	#		"10.0.0.0/16"
	#	  ]
	#	},
	#	"ddosProtectionPlan": null,
	#	"dhcpOptions": null,
	#	"enableDdosProtection": false,
	#	"enableVmProtection": false,
	#	"etag": "W/\"07486bc2-be4c-461e-b3d4-009ad2999115\"",
	#	"id": "/subscriptions/6187b663-b744-4d24-8226-7e66525baf8f/resourceGroups/rbaAccumulo7-rg/providers/Microsoft.Network/virtualNetworks/rbaJumpBox-vmVNET",
	#	"location": "eastus",
	#	"name": "rbaJumpBox-vmVNET",
	
#			vnet = <your vnet, from the portal>
#				example: rbaJumpBox-vmVNET
#			vnet_cidr = <your vnet address space, from the portal>
#				example: 10.0.0.0/16
#			subnet = <your subnet, from the portal>
#				example: rbaJumpBox-vmSubnet
#			subnet_cidr = <your subnet address space, from the portal>
#				example: 10.0.0.0/24
#			numnodes = 20
#			vm_sku = Standard_D16s_v3
#			location = <your region>
#				example: northeurope
