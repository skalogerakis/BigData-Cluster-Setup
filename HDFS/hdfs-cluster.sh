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
HADOOP_MASTER=""
HADOOP_WORKERS=""

download='true'

#Function that checks whether an env variable is defined or not
env_variable_exists_checker(){
	temp=$1
	temp2=$2


	if [ -z "${temp}" ] ; then
		echo "##### ENVIRONMENT VARIABLE NOT DEFINED. #####"	
		echo "##### DEFINE IN THE PATH -> ${temp2} #####" 
		sudo sh -c "echo 'export ${temp2}' >> /etc/profile"
		source /etc/profile
		if [[ $temp2 == JAVA_HOME* ]] ; then
			sudo sh -c "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> /etc/profile"
		elif [[ $temp2 == HADOOP_HOME* ]]; then
			sudo sh -c "echo 'export PATH=\$HADOOP_HOME/bin:\$PATH' >> /etc/profile"
		fi
	else
		echo "##### ENVIRONMENT VARIABLE -> ${temp} DEFINED. SKIP THAT STEP #####"

	fi
	echo ""
}


if [ $# -eq 0 ]
then
	echo "######### DEFAULT BEHAVIOR. HADOOP VERSION -> ${HADOOP_VERSION} #########"
else

	while test $# -gt 0; do
	  case "$1" in
	    -h|--help)
	      echo "options:"
	      echo "-h, --help              	Show brief help"
	      echo "-hadoop, --hadoop		  	  Specify the Hadoop version to download. Default: hadoop-3.3.1"
	      echo "-d, --downloaded		  		Already downloaded binaries flags. (For Config sync). "
	      echo "-w, --workers		  				Specify the comma delimitered IPs for the Hadoop worker nodes (Non-Optional parameter)"
	      echo "-m, --master		  				Specify the IP for the Hadoop master node (Non-Optional parameter)"
	      exit 0
	      ;;
	    -hadoop|--hadoop)
	      shift

	      if test $# -gt 0; then
	        HADOOP_VERSION=$1
	        echo "######### MODIFIED THE DEFAULT HADOOP VERSION #########"
	      fi
	      shift
	      ;;
	    -w|--workers)
	      shift

	      if test $# -gt 0; then
	        HADOOP_WORKERS=$1
	        echo "######### HADOOP_WORKERS -> ${HADOOP_WORKERS} #########"
	      fi
	      shift
	      ;;
	    -m|--master)
	      shift
	      if test $# -gt 0; then
	        HADOOP_MASTER=$1
	        echo "######### HADOOP_MASTER -> ${HADOOP_MASTER} #########"
	      fi
	      shift
	      ;;
	    -d|--downloaded)
	      shift
	      download='false'
	      ;;
	    *)
	      break
	      ;;
	  esac
	done
fi

# If either of flink master and workers are not defined exit
if [[ -z $HADOOP_MASTER || -z $HADOOP_WORKERS ]]; then
	echo "######### BOTH HADOOP MASTER AND WORKERS MUST BE SPECIFIED. EXITING.... "
	exit -1
fi


if [ "$download" = true ] ; then

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



	tar -xvf ${HADOOP_VERSION}.tar.gz --directory $HOME --one-top-level=hadoop --strip-components 1




	# Export the env variables
	# echo 'export HADOOP_HOME=$HOME/hadoop' >> ~/.bashrc
	# echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> ~/.bashrc
	# echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc
	# echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc
	# echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc
	# echo 'export YARN_HOME=$HADOOP_HOME' >> ~/.bashrc
	# echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc

	# echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre' >> ~/.bashrc
	# echo 'export PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin:$PATH' >> ~/.bashrc
	# echo 'export HADOOP_CLASSPATH=$(hadoop classpath)' >> ~/.bashrc

	# . ~/.bashrc

	env_variable_exists_checker "$HADOOP_HOME" HADOOP_HOME=\$HOME/hadoop

	env_variable_exists_checker "$HADOOP_CONF_DIR" HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
	env_variable_exists_checker "$HADOOP_MAPRED_HOME" HADOOP_MAPRED_HOME=\$HADOOP_HOME
	env_variable_exists_checker "$HADOOP_COMMON_HOME" HADOOP_COMMON_HOME=\$HADOOP_HOME
	env_variable_exists_checker "$HADOOP_HDFS_HOME" HADOOP_HDFS_HOME=\$HADOOP_HOME
	env_variable_exists_checker "$YARN_HOME" YARN_HOME=\$HADOOP_HOME

	env_variable_exists_checker "$HADOOP_CLASSPATH" HADOOP_CLASSPATH=\$"(hadoop classpath)"

	env_variable_exists_checker "$JAVA_HOME" JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

	echo "ENVIRONMENT VARIABLES ACTIVATED"

	sleep 2

fi


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
