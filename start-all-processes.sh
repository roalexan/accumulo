#!/bin/bash

#
# Start all processes - zookeeper, dfs, yarn, and accumulo
#

cd ~
rm --force ./start-all-processes.log
exec > >(tee --append ./start-all-processes.log)
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


echo "start zookeeper"
ssh ${adminUsername}@${nameserviceId}-0 "~/install/zookeeper-3.4.14/bin/zkServer.sh start"
ssh ${adminUsername}@${nameserviceId}-1 "~/install/zookeeper-3.4.14/bin/zkServer.sh start"
ssh ${adminUsername}@${nameserviceId}-2 "~/install/zookeeper-3.4.14/bin/zkServer.sh start"

echo "start dfs"
ssh ${adminUsername}@${nameserviceId}-0 "~/install/hadoop-3.2.0/sbin/start-dfs.sh"

echo "start yarn"
ssh ${adminUsername}@${nameserviceId}-0 "~/install/hadoop-3.2.0/sbin/start-yarn.sh"

echo "start accumulo"
ssh ${adminUsername}@${nameserviceId}-0 "~/install/accumulo-2.0.0/bin/accumulo-cluster start"
