dataSize="1G"
adminusername="rba1"
hostname="4nodecluster-0"
ssh -T -o "StrictHostKeyChecking no" ${adminusername}@${hostname} << EOF
adminUsername=$(whoami)
echo "dataSize: ${dataSize}"
echo "adminUsername: ${adminUsername}"
JAR="file:////home/${adminUsername}/webscale-ai-test/target/accumulo-spark-shaded.jar"
echo "JAR: ${JAR}"
EOF
