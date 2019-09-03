#!/bin/bash
cd ~

echoerr() {
	echo "$@" 1>&2;
}

date | tee setup-cluster.log
echo "Read the options" | tee --append setup-cluster.log
TEMP=`getopt -o a:p:t:s:g --long app-id:,password:,tenant-id:,subscription-id:,resource-group: -- "$@"`
eval set -- "$TEMP"

echo "Extract options and their arguments into variables" | tee --append setup-cluster.log
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
        *) echoerr "ERROR: Unable to get variables from arguments" ; exit 1 ;;
    esac
done
if [ -z "$appId" ]
then
    echoerr "Missing required argument: -a | app-id" | tee --append setup-cluster.log
    exit 1
fi
if [ -z "$password" ]
then
    echoerr "Missing required argument: -p | password" | tee --append setup-cluster.log
    exit 1
fi
if [ -z "$tenantId" ]
then
    echoerr "Missing required argument: -t | tenant-id" | tee --append setup-cluster.log
    exit 1
fi
if [ -z "$subscriptionId" ]
then
    echoerr "Missing required argument: -s | subscription-id" | tee --append setup-cluster.log
    exit 1
fi
if [ -z "$resourceGroup" ]
then
    echoerr "Missing required argument: -g | resource-group" | tee --append setup-cluster.log
    exit 1
fi

echo "Install Python 3.6 and create a virtual environment" | tee --append setup-cluster.log
#sudo yum install -y epel-release
#sudo yum install -y python36 python36-devel python36-setuptools
#sudo python36 /usr/lib/python3.6/site-packages/easy_install.py pip
#python3.6 -m venv ~/env
#source ~/env/bin/activate

echo "Install Ansible and VMSS (virtual machine scale set) patch" | tee --append setup-cluster.log
#sudo yum check-update
#sudo yum install -y gcc libffi-devel python-devel openssl-devel
#sudo yum install -y python-pip python-wheel
#pip install ansible[azure]
#sudo yum -y install git
#git clone https://github.com/ansible/ansible
#cp ansible/lib/ansible/modules/cloud/azure/azure_rm_virtualmachinescaleset.py env/lib/python3.6/site-packages/ansible/modules/cloud/azure/

echo "Download the Magna Carta repo zip" | tee --append setup-cluster.log
#ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
#mkdir ~/fluo-muchos
#wget https://roalexan.blob.core.windows.net/accumulo/fluo-muchos.zip --output-document ~/fluo-muchos/fluo-muchos.zip
#unzip ~/fluo-muchos/fluo-muchos.zip -d ~/fluo-muchos

echo "Setup agent forwarding" | tee --append setup-cluster.log
#export ANSIBLE_HOST_KEY_CHECKING=False
#export ANSIBLE_LOG_PATH=~/play.log
#eval $(ssh-agent -s)
#ssh-add ~/.ssh/id_rsa

echo "Install Azure CLI" | tee --append setup-cluster.log
#sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
#sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
#sudo yum install -y azure-cli
#sed -i '/^PYTHONPATH=/c\PYTHONPATH=/usr/lib64/az/lib/python2.7/site-packages python2 -sm azure.cli "$@"' $(which az)
#az login --service-principal --username "$APP_ID" --password "$PASSWORD" --tenant "$TENANT_ID"
#az account set --subscription "$subscriptionId"

echo "Update muchos.props" | tee --append setup-cluster.log
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
