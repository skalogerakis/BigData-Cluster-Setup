#!/bin/bash -i

FLINK_MASTER="192.168.2.1834"
FLINK_WORKERS="127.3.2.41,127.3.2.51,127.3.2.91"


# Steps to setup Flink cluster 
# Step 1) Download the desired version of Flink
# Step 2) Untar the downloaded file with the binaries
# Step 3) Modify the flink-conf.yaml, workers, master to match the desired requirements
# Step 4) Sync the desired configurations
# Step 5) Start cluster

FLINK_VERSION="flink-1.13.2"
SCALA_VERSION="scala_2.12"
# TODO maybe add download as an option
URL="https://ftp.cc.uoc.gr/mirrors/apache/flink/${FLINK_VERSION}/${FLINK_VERSION}-bin-${SCALA_VERSION}.tgz"
# https://archive.apache.org/dist/flink/flink-1.13.2/flink-1.13.2-src.tgz
# flink-1.11.4-bin-scala_2.12.tgz 
ARCHIVE_URL="https://archive.apache.org/dist/flink/${FLINK_VERSION}/${FLINK_VERSION}-bin-${SCALA_VERSION}.tgz"

# Try to find the hadoop version in the latest apache download pages and the archive. If the given version
# is not found in one of the two, then possibly it does not exist
if wget "$URL" || wget "$ARCHIVE_URL" 
then
	echo \n\n
	echo "DOWNLOAD COMPLETED SUCCESSFULLY"
else
	echo ERROR: Failed to find the ${HADOOP_VERSION}. Make sure that the version is spelled correctly.
	exit -1
fi

tar -xvf ${FLINK_VERSION}-bin-${SCALA_VERSION}.tgz --directory $HOME --one-top-level=flink --strip-components 1

echo 'export FLINK_HOME=$HOME/flink' >> ~/.bashrc

. ~/.bashrc

echo "ENVIRONMENT VARIABLES ACTIVATED"

echo "MODIFY FILES TO MATCH CLUSTER SPECS"

sed -i "s+^jobmanager.rpc.address:.*+jobmanager.rpc.address: ${FLINK_MASTER}+g" Cluster/flink-conf.yaml
sed -i "s+^.*:8081+${FLINK_MASTER}:8081+g" Cluster/masters
sed -i "s+^localhost++g" Cluster/workers

# Loop the Worker IP's
for i in $(echo $FLINK_WORKERS | tr "," "\n")
do
  # process
  echo ${i} >> Cluster/workers
done


sleep 2

echo "START FILE SYNC"
rsync -raz --progress Cluster/ $FLINK_HOME/conf/