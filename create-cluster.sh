#!/bin/bash
cd ~
rm --force ./create-cluster.log
exec > >(tee --append ./create-cluster.log)
exec 2>&1

date
echo "Read the options"
TEMP=`getopt -o a:p:t:s:n --long spappid:,sppassword:,sptenantid:,subscription:,nameserviceid: -- "$@"`
eval set -- "$TEMP"

echo "Extract options and their arguments into variables"
while true ; do
    case "$1" in
        -a|--spappid)
            spappid=$2 ; shift 2;;
        -p|--sppassword)
            sppassword=$2 ; shift 2;;
        -t|--sptenantid)
            sptenantid=$2 ; shift 2;;
        -s|--subscription)
            subscription=$2 ; shift 2;;
        -n|--nameserviceid)
            nameserviceid=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "ERROR: Unable to get variables from arguments" ; exit 1 ;;
    esac
done
if [ -z "$spappid" ]
then
    echo "Missing required argument: -a | spappid"
    exit 1
fi
if [ -z "$sppassword" ]
then
    echo "Missing required argument: -p | sppassword"
    exit 1
fi
if [ -z "$sptenantid" ]
then
    echo "Missing required argument: -t | sptenantid"
    exit 1
fi
if [ -z "$subscription" ]
then
    echo "Missing required argument: -s | subscription"
    exit 1
fi
if [ -z "$nameserviceid" ]
then
    echo "Missing required argument: -n | nameserviceid"
    exit 1
fi

echo "Activate python environment"
source ~/env/bin/activate

echo "Azure CLI"
az login --service-principal --username $spappid --password $sppassword --tenant $sptenantid
az account set --subscription $subscription

echo "Setup agent forwarding"
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_LOG_PATH=~/play.log
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

echo "Run launch script"
cd ~/fluo-muchos/bin
./muchos launch --cluster $nameserviceId
		
echo "Run setup script"
sed -i "s/zkfc/zkfc,spark/" ~/fluo-muchos/conf/muchos.props
./muchos setup --cluster $nameserviceId
