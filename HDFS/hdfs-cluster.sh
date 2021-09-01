#!/bin/bash -i


# Steps to setup a standalone HDFS cluster
# Step 1) Download the desired hadoop version
# Step 2) Untar the downloaded file
# Step 3) Move the file to the desired directory(by default the $HOME directory) and rename to hadoop to make things easier
# Step 4) Export the needed env. variables (Don't forget to activate them in the current shell using source command)
# Step 5) Overwrite the default config files in $HADOOP_HOME/etc/hadoop with the custom configs found in the folder confFiles. 
# In the cluster case, also add worker nodes and modify the core-site accordingly to match the master IP
# Step 6) To grant permission generate ssh-keygen
# Step 7) Check the current IP and if it matches the namenode then format. NOTE: It is important to setup workers first and then the namenodes

HADOOP_VERSION="hadoop-3.3.1"
HADOOP_MASTER="83.212.109.203"
HADOOP_WORKERS="83.212.109.198,83.212.101.207"

# TODO maybe add download as an option
URL="https://ftp.cc.uoc.gr/mirrors/apache/hadoop/common/${HADOOP_VERSION}/${HADOOP_VERSION}.tar.gz"
ARCHIVE_URL="https://archive.apache.org/dist/hadoop/common/${HADOOP_VERSION}/${HADOOP_VERSION}.tar.gz"

# Try to find the hadoop version in the latest apache download pages and the archive. If the given version
# is not found in one of the two, then possibly it does not exist
if wget "$URL"|| wget "$ARCHIVE_URL" 
then
	echo \n\n
	echo "DOWNLOAD COMPLETED SUCCESSFULLY"
else
	echo ERROR: Failed to find the ${HADOOP_VERSION}. Make sure that the version is spelled correctly.
	exit -1
fi

# TODO handle untar error. 
:'
Both tar commands work in the same way. The goal is to rename the final directory to hadoop. TODO check if the
first one creates any issues but it seems the best way to go.
'

tar -xvf ${HADOOP_VERSION}.tar.gz --directory $HOME --one-top-level=hadoop --strip-components 1

# tar -xvf ${HADOOP_VERSION}.tar.gz --directory $HOME 
# mv $HOME/${HADOOP_VERSION} $HOME/hadoop


# Export the env variables
echo 'export HADOOP_HOME=$HOME/hadoop' >> ~/.bashrc
echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export YARN_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc

echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre' >> ~/.bashrc
echo 'export PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin:$PATH' >> ~/.bashrc
echo 'export HADOOP_CLASSPATH=$(hadoop classpath)' >> ~/.bashrc

. ~/.bashrc

echo "ENVIRONMENT VARIABLES ACTIVATED"

sleep 2

echo "Hadoop Home -> "$HADOOP_HOME


echo "MODIFY FILES TO MATCH CLUSTER SPECS"

sed -i "s+^<value>hdfs://.*:9000</value>+<value>hdfs://${HADOOP_MASTER}:9000</value>+g" Cluster/core-site.xml
sed -i "s+^localhost++g" Cluster/workers

# Loop the Worker IP's
for i in $(echo $HADOOP_WORKERS | tr "," "\n")
do
  # process
  echo ${i} >> Cluster/workers
done

sleep 2

echo "START FILE SYNC"
rsync -raz --progress Cluster/ $HADOOP_HOME/etc/hadoop/

# Solves permission denied issue
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

sleep 2

# Fetch the machine from the running IP
nameNodeCheck=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
echo "CURRENT IP: "$nameNodeCheck

if [ $nameNodeCheck = $HADOOP_MASTER ] 
then
	echo "MASTER NODE.FORMAT HDFS CLUSTER"
	hdfs namenode -format
else
	echo "WORKER NODE. FORMAT HDFS CLUSTER"
	hdfs namenode -format
fi
