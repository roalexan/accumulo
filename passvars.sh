cd ~
rm --force ./passvars.log
exec > >(tee --append ./passvars.log)
exec 2>&1

adminusername="rba1"
hostname="4nodecluster-0"
ssh -T -o "StrictHostKeyChecking no" ${adminusername}@${hostname} << EOF
adminUsername=$(whoami)
echo "adminUsername: ${adminUsername}"
echo "dataSize: ${dataSize}"
JAR="file:////home/${adminUsername}/webscale-ai-test/target/accumulo-spark-shaded.jar"
echo "JAR: ${JAR}"
EOF
