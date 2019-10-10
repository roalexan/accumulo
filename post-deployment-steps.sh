#!/bin/bash

#
# Do all the post-deployment steps on the Accumulo cluster
#

cd ~
rm --force ./post-deployment-steps.log
exec > >(tee --append ./post-deployment-steps.log)
exec 2>&1

date
echo "Read the options"
TEMP=`getopt -o a:p:t:s:g:n:u --long spappid:,sppassword:,sptenantid:,subscription:,resource-group:,nameserviceid:,admin-username: -- "$@"`
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
        -g|--resource-group)
            resourcegroup=$2 ; shift 2;;
        -n|--nameserviceid)
            nameserviceid=$2 ; shift 2;;
        -u|--admin-username)
            adminusername=$2 ; shift 2;;
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
if [ -z "$resourcegroup" ]
then
    echo "Missing required argument: -g | resource-group"
    exit 1
fi
if [ -z "$nameserviceid" ]
then
    echo "Missing required argument: -n | nameserviceid"
    exit 1
fi
if [ -z "$adminusername" ]
then
    echo "Missing required argument: -u | admin-username"
    exit 1
fi

echo "Update yarn configs for all nodes"
# https://stackoverflow.com/questions/7619438/bash-read-a-file-line-by-line-and-process-each-segment-as-parameters-to-other-p#7619467
while read hostname ipaddress
do
	# https://stackoverflow.com/questions/6351022/executing-ssh-command-in-a-bash-shell-script-within-a-loop
	# https://superuser.com/questions/125324/how-can-i-avoid-sshs-host-verification-for-known-hosts
	echo "set properties in "${hostname}
	ssh -T -o "StrictHostKeyChecking no" ${adminusername}@${hostname} << 'EOF'
	echo "set yarn.nodemanager.resource.memory-mb"
	sed -i '/yarn.nodemanager.resource.memory-mb/{n; s/<value>.*<\/value>/<value>32768<\/value>/}' ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml
	echo "set yarn.scheduler.maximum-allocation-mb"
	if ! grep -q yarn.scheduler.maximum-allocation-mb ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml; then
		lineIndex=`sed -n '/yarn.nodemanager.resource.memory-mb/=' ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml`
		lineIndex=$(($lineIndex + 2))
		elem="<property>\n\t\t<name>yarn.scheduler.maximum-allocation-mb</name>\n\t\t<value>32768</value>\n\t</property>"
		elem=$(echo $elem | sed 's/\//\\\//g')
		sed -i "${lineIndex}a\\\t${elem}" ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml
	fi
	echo "set spark.yarn.am.cores"
	if ! grep -q spark.yarn.am.cores ~/install/spark-2.4.3-bin-without-hadoop/conf/spark-defaults.conf; then
		echo "spark.yarn.am.cores                4" >> ~/install/spark-2.4.3-bin-without-hadoop/conf/spark-defaults.conf 
	fi
	echo "set spark.yarn.am.memory"
	if ! grep -q spark.yarn.am.memory ~/install/spark-2.4.3-bin-without-hadoop/conf/spark-defaults.conf; then
		echo "spark.yarn.am.memory               12g" >> ~/install/spark-2.4.3-bin-without-hadoop/conf/spark-defaults.conf 
	fi
EOF
done < ~/fluo-muchos/conf/hosts/${nameserviceid}

echo "login Azure CLI using service principal"
az login --service-principal --username ${spappid} --password ${sppassword} --tenant ${sptenantid}

echo "set subscription"
az account set --subscription ${subscription}

echo "set default resource group"
az configure --defaults group=${resourcegroup}

echo "Restart scale set"
az vmss restart --resource-group ${resourcegroup} --name ${nameserviceid}

echo "start zookeepers"
head -3 ~/fluo-muchos/conf/hosts/${nameserviceid} |
while read hostname ipaddress
do
	echo "start zookeeper - hostname: ${hostname}, ipaddress: ${ipaddress}"
        ssh -n -o "StrictHostKeyChecking no" ${adminusername}@${hostname} "~/install/zookeeper-3.4.14/bin/zkServer.sh start"
done

read hostname ipaddress < ~/fluo-muchos/conf/hosts/${nameserviceid}
echo "master - hostname: ${hostname}, ipaddress: ${ipaddress}"

echo "start dfs"
ssh -o "StrictHostKeyChecking no" ${adminusername}@${hostname} "~/install/hadoop-3.2.0/sbin/start-dfs.sh"

echo "start yarn"
ssh -o "StrictHostKeyChecking no" ${adminusername}@${hostname} "~/install/hadoop-3.2.0/sbin/start-yarn.sh"

echo "start accumulo"
ssh -o "StrictHostKeyChecking no" ${adminusername}@${hostname} "~/install/accumulo-2.0.0/bin/accumulo-cluster start"

echo "Log into master node"
ssh -T -o "StrictHostKeyChecking no" ${adminusername}@${hostname} << 'EOF'

echo "Build accumulo jar"
BUILD_DIR="webscale-ai-test"
cd ~
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}
wget https://roalexan.blob.core.windows.net/webscale-ai/accumulo_scala.yaml
wget https://roalexan.blob.core.windows.net/webscale-ai/pom.xml
mvn clean package -P create-shade-jar

echo "Install Anaconda"
ANACONDA="https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh"
curl ${ANACONDA} -o anaconda.sh
/bin/bash anaconda.sh -b -p ${HOME}/conda
rm anaconda.sh
echo ". ${HOME}/conda/etc/profile.d/conda.sh" >> ~/.bashrc
echo "conda activate base" >> ~/.bashrc
PATH="${HOME}/conda/bin:${PATH}"
source ~/.bashrc

echo "Install krb5-devel"
sudo yum install -y krb5-devel

echo "Create conda environment"
conda env create -f accumulo_scala.yaml

echo "Activate conda environment"
conda activate accumulo

echo "Create jupyter kernel"
adminUsername=$(whoami)
JAR="file:////home/${adminUsername}/webscale-ai-test/target/accumulo-spark-shaded.jar"
echo "JAR: ${JAR}"
jupyter toree install \
    --replace \
    --user \
    --kernel_name=accumulo \
    --spark_home=${SPARK_HOME} \
    --spark_opts="--master yarn --jars ${JAR} \
        --packages com.microsoft.ml.spark:mmlspark_2.11:0.18.1 \
        --driver-memory 16g \
        --executor-memory 12g \
        --driver-cores 4 \
        --executor-cores 4 \
        --num-executors 64"
	
DATA_FILE="sentiment140_prefix.csv"
wget https://roalexan.blob.core.windows.net/webscale-ai/${DATA_FILE}
hdfs dfs -mkdir -p /user/${adminUsername}
hdfs dfs -put ${DATA_FILE} ${DATA_FILE}
hdfs dfs -ls /user/${adminUsername}
cp ${HOME}/install/accumulo-2.0.0/conf/accumulo-client.properties .
NOTEBOOK_FILE="baseline_colocated_spark_train.ipynb"
wget https://roalexan.blob.core.windows.net/webscale-ai/${NOTEBOOK_FILE}
papermill ${NOTEBOOK_FILE} results.ipynb -p DATA_SIZE 1G

echo "Get results from HDFS"
hdfs dfs -get /user/${adminUsername}/results/*.csv .
echo "Install AzureML SDK"
pip install --upgrade azureml-sdk

echo "spappid: ${spappid}"

EOF
