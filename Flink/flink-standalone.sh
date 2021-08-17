#!/bin/bash -i


# Steps to setup Flink standalone 
# Step 1) Download the desired version of Flink
# Step 2) Untar the downloaded file with the binaries
# Step 3) Sync the desired configurations
# Step 4) Start cluster

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

sleep 2

echo "START FILE SYNC"

rsync -raz --progress Standalone/ $FLINK_HOME/conf/
