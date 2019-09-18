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

# https://stackoverflow.com/questions/7619438/bash-read-a-file-line-by-line-and-process-each-segment-as-parameters-to-other-p#7619467
while read hostname ipaddress
do
	echo "set yarn.nodemanager.resource.memory-mb in "$hostname
	# https://stackoverflow.com/questions/6351022/executing-ssh-command-in-a-bash-shell-script-within-a-loop
	# https://superuser.com/questions/125324/how-can-i-avoid-sshs-host-verification-for-known-hosts
	ssh -n -o "StrictHostKeyChecking no" $adminUsername@$hostname "sed -i '/yarn.nodemanager.resource.memory-mb/{n; s/<value>.*<\/value>/<value>32768<\/value>/}' ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml"
	
	echo "set yarn.scheduler.maximum-allocation-mb in "$hostname
	if ! grep -q yarn.scheduler.maximum-allocation-mb ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml; then
		ssh -T -o "StrictHostKeyChecking no" $adminUsername@$hostname << 'EOF'
		lineIndex=`sed -n '/yarn.nodemanager.resource.memory-mb/=' ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml`
		lineIndex=$(($lineIndex + 2))
		elem="<property>\n\t\t<name>yarn.scheduler.maximum-allocation-mb</name>\n\t\t<value>32768</value>\n\t</property>"
		elem=$(echo $elem | sed 's/\//\\\//g')
		sed -i "${lineIndex}a\\\t${elem}" ~/install/hadoop-3.2.0/etc/hadoop/yarn-site.xml
EOF
	fi
done < ~/fluo-muchos/conf/hosts/$nameserviceId
