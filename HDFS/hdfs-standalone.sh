#!/bin/bash -i


# Steps to setup a standalone HDFS cluster
# Step 1) Download the desired hadoop version
# Step 2) Untar the downloaded file
# Step 3) Move the file to the desired directory(by default the $HOME directory) and rename to hadoop to make things easier
# Step 4) Export the needed env. variables (Don't forget to activate them in the current shell using source command)
# Step 5) Overwrite the default config files in $HADOOP_HOME/etc/hadoop with the custom configs found in the folder confFiles
# Step 6) To grant permission generate ssh-keygen
# Step 7) Format the HDFS namenode to get things ready

HADOOP_VERSION="hadoop-3.3.1"
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
	      echo "-h, --help                	show brief help"
	      echo "-hadoop, --hadoop		  	Specify the Hadoop version to download. Default: hadoop-3.3.1"
	      echo "-d, --downloaded		  	Already downloaded binaries flags. (For Config sync). "
	      exit 0
	      ;;
	    -s|--source)
	      shift
	      source_option='true'
	      ;;
	    -hadoop|--hadoop)
	      shift

	      if test $# -gt 0; then
	        HADOOP_VERSION=$1
	        echo "######### MODIFIED THE DEFAULT HADOOP VERSION #########"
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

	# Apply changes in order to avoid other issues
	# source /etc/profile

	echo "ENVIRONMENT VARIABLES ACTIVATED"

	sleep 2


fi


echo "START FILE SYNC"

rsync -raz --progress Standalone/ $HADOOP_HOME/etc/hadoop/

# Solves permission denied issue
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

sleep 2

echo "FORMAT HDFS CLUSTER"

hdfs namenode -format