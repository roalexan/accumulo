  
#!/bin/bash

#
# Create environment and start jupyter notebook
#

cd ~
rm --force ./jupyter-setup.log
exec > >(tee --append ./jupyter-setup.log)
exec 2>&1

date
echo "Read the options"
TEMP=`getopt -o u:i --long admin-username:,nameservice-id: -- "$@"`
eval set -- "$TEMP"

echo "Extract options and their arguments into variables"
while true ; do
    case "$1" in
        -u|--admin-username)
            adminUsername=$2 ; shift 2;;
        -i|--nameservice-id)
            nameserviceId=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "ERROR: Unable to get variables from arguments" ; exit 1 ;;
    esac
done

if [ -z "$adminUsername" ]
then
    echo "Missing required argument: -u | admin-username"
    exit 1
fi
if [ -z "$nameserviceId" ]
then
    echo "Missing required argument: -i | nameservice-id"
    exit 1
fi

ssh -T -o "StrictHostKeyChecking no" ${adminUsername}@${nameserviceId}-0 << 'EOF'

ssh ${adminUsername}@${nameserviceId}-0 "~/install/zookeeper-3.4.14/bin/zkServer.sh start"
    mkdir webscale-ai-test
    cd webscale-ai-test
    wget https://roalexan.blob.core.windows.net/webscale-ai/accumulo_scala.yaml --output-document accumulo_scala.yaml
    wget https://roalexan.blob.core.windows.net/webscale-ai/pom.xml --output-document pom.xml
    mvn clean package -P create-shade-jar
    cd /tmp
    curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh
    bash Anaconda3-5.3.1-Linux-x86_64.sh
EOF



---



mkdir webscale-ai-test
cd webscale-ai-test
wget https://roalexan.blob.core.windows.net/webscale-ai/accumulo_scala.yaml --output-document accumulo_scala.yaml
wget https://roalexan.blob.core.windows.net/webscale-ai/pom.xml --output-document pom.xml

3. Build an Accumulo fat jar

mvn clean package -P create-shade-jar

4. Install conda

instructions: https://linuxize.com/post/how-to-install-anaconda-on-centos-7/

cd /tmp
curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh
bash Anaconda3-5.3.1-Linux-x86_64.sh
(accept defaults, except vscode)
source ~/.bashrc

5. Create conda environment

cd ~/webscale-ai-test

sudo yum install -y krb5-devel

ensure accumulo_scale.yaml looks like this:

name: accumulo
channels:
- defaults
- conda-forge
dependencies:
- ipykernel>=4.6.1
- jupyter>=1.0.0
- numpy>=1.13.3
- pandas>=0.23.4
- python==2.7.14
- pip:
  - thrift==0.11.0
  - toree
  - sparkmagic

conda env create -f accumulo_scala.yaml

6. Activate conda environment

conda activate accumulo

7. Start Toree kernel

JAR="file:////home/rba1/webscale-ai-test/target/accumulo-spark-shaded.jar"
jupyter toree install \
    --replace \
    --user \
    --kernel_name=accumulo \
    --spark_home=${SPARK_HOME} \
    --spark_opts="--master yarn --jars $JAR \
        --packages com.microsoft.ml.spark:mmlspark_2.11:0.18.1 \
        --driver-memory 16g \
        --executor-memory 12g \
        --driver-cores 4 \
        --executor-cores 4 \
        --num-executors 64"
