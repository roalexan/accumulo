cd ~
rm --force ./passvars.log
exec > >(tee --append ./passvars.log)
exec 2>&1

date
echo "Read the options"
TEMP=`getopt -o d --long data-size: -- "$@"`
eval set -- "$TEMP"

echo "Extract options and their arguments into variables"
while true ; do
    case "$1" in
        -d|--data-size)
            dataSize=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "ERROR: Unable to get variables from arguments" ; exit 1 ;;
    esac
done

if [ -z "$dataSize" ]
then
    echo "Missing required argument: -d | data-size"
    exit 1
fi

echo "dataSize 1: ${dataSize}"

adminusername="rba1"
hostname="4nodecluster-0"
ssh -T -o "StrictHostKeyChecking no" ${adminusername}@${hostname} << EOF
adminUsername=$(whoami)
echo "adminUsername: ${adminUsername}"
echo "dataSize: ${dataSize}"
JAR="file:////home/${adminUsername}/webscale-ai-test/target/accumulo-spark-shaded.jar"
echo "JAR: ${JAR}"
EOF
