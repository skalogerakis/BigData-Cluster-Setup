#!/bin/bash -i


# Steps to setup Flink standalone 
# Step 1) Download the desired version of Flink
# Step 2) Untar the downloaded file with the binaries
# Step 3) Sync the desired configurations
# Step 4) Start cluster

# TODO IMPORTANT -> Must reboot in order the env variables to take effect


source_option='false'
FLINK_VERSION="flink-1.13.1"
SCALA_VERSION="scala_2.12"
download='true'


#Function that checks whether an env variable is defined or not
env_variable_exists_checker(){
	temp=$1
	temp2=$2


	if [ -z "${temp}" ] ; then
		echo "##### ENVIRONMENT VARIABLE NOT DEFINED. #####"	
		echo "##### DEFINE IN THE PATH -> ${temp2} #####" 
		sudo sh -c "echo 'export ${temp2}' >> /etc/profile"
		if [[ $temp2 == JAVA_HOME* ]] ; then
			sudo sh -c "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> /etc/profile"
		fi
	else
		echo "##### ENVIRONMENT VARIABLE -> ${temp} DEFINED. SKIP THAT STEP #####"

	fi
	echo ""
}


if [ $# -eq 0 ]
then
	echo "######### DEFAULT BEHAVIOR. FLINK VERSION -> ${FLINK_VERSION}, SCALA_VERSION -> ${SCALA_VERSION} #########"

else

	while test $# -gt 0; do
	  case "$1" in
	    -h|--help)
	      echo "options:"
	      echo "-h, --help                show brief help"
	      echo "-source, --source		  Build from sources flag. "
	      echo "-flink, --flink		  	  Specify the Flink version to download. Default: flink-1.13.1"
	      echo "-scala, --scala		  	  Specify the Scala version. Default: scala_2.12"
	      echo "-d, --downloaded		  Already downloaded binaries flags. (For Config sync). "
	      exit 0
	      ;;
	    -s|--source)
	      shift
	      source_option='true'
	      ;;
	    -flink|--flink)
	      shift

	      if test $# -gt 0; then
	        FLINK_VERSION=$1
	        echo "######### MODIFIED THE DEFAULT FLINK VERSION #########"
	      fi
	      shift
	      ;;
	    -scala|--scala)
	      shift
	      if test $# -gt 0; then
	        SCALA_VERSION=$1
	        echo "######### MODIFIED THE DEFAULT SCALA VERSION #########"
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


if [ "$source_option" = true ] ; then
	# TODO For now assume that everything is on $HOME DIR 

    echo "######### BUILDING FROM SOURCES OPTION #########"

    source /etc/profile
    env_variable_exists_checker "$FLINK_HOME" FLINK_HOME=\$HOME/build-target
	env_variable_exists_checker "$JAVA_HOME" JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	
	# Apply changes in order to avoid other issues
	source /etc/profile

	echo "ENVIRONMENT VARIABLES ACTIVATED"
	
	sleep 2
	
	# HADOOP CLASSPATH IN /etc/profile solved the issue with HDFS dependency
	# NO NEED FOR EXTRA JAR. IN CASE SOMETHING GOES WRONG RETURN TO THIS
  #   if [ "$download" = true ] ; then


		# # echo 'export FLINK_HOME=$HOME/flink/build-target' >> ~/.bashrc

		# # . ~/.bashrc
		

		# HADOOP_URL="https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/flink/flink-shaded-hadoop-3-uber/3.1.1.7.2.8.0-224-9.0/flink-shaded-hadoop-3-uber-3.1.1.7.2.8.0-224-9.0.jar"

		# if wget -P $FLINK_HOME/lib/ "$HADOOP_URL" 
		# then
		# 	echo \n\n
		# 	echo "######### DOWNLOADED HADOOP 3.x DEPENDENCY #########"
		# else
		# 	echo "ERROR -> FAILED TO DOWNLOAD THE HADOOP DEPENDENCY. THIS MAY LEAD TO UNEXPECTED BEHAVIOR"
		# fi

  #   fi

    
	echo "######### START CONFIG SYNC #########"

	rsync -raz --progress Standalone/ $FLINK_HOME/conf/

else
	echo "######### BUILDING FROM BINARIES #########"

	if [ "$download" = true ] ; then

		URL="https://ftp.cc.uoc.gr/mirrors/apache/flink/${FLINK_VERSION}/${FLINK_VERSION}-bin-${SCALA_VERSION}.tgz"
		# https://archive.apache.org/dist/flink/flink-1.13.2/flink-1.13.2-src.tgz
		# flink-1.11.4-bin-scala_2.12.tgz 
		ARCHIVE_URL="https://archive.apache.org/dist/flink/${FLINK_VERSION}/${FLINK_VERSION}-bin-${SCALA_VERSION}.tgz"

		# Try to find the flink version in the latest apache download pages and the archive. If the given version
		# is not found in one of the two, then possibly it does not exist
		if wget "$URL" || wget "$ARCHIVE_URL" 
		then
			echo \n\n
			echo "######### DOWNLOAD COMPLETED SUCCESSFULLY #########"
		else
			echo ERROR: Failed to find the ${FLINK_VERSION}. Make sure that the version is spelled correctly.
			exit -1
		fi

		tar -xvf ${FLINK_VERSION}-bin-${SCALA_VERSION}.tgz --directory $HOME --one-top-level=flink --strip-components 1

		# HADOOP CLASSPATH IN /etc/profile solved the issue with HDFS dependency
		# HADOOP_URL="https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/flink/flink-shaded-hadoop-3-uber/3.1.1.7.2.8.0-224-9.0/flink-shaded-hadoop-3-uber-3.1.1.7.2.8.0-224-9.0.jar"

		# if wget -P $FLINK_HOME/lib/ "$HADOOP_URL" 
		# then
		# 	echo \n\n
		# 	echo "######### DOWNLOADED HADOOP 3.x DEPENDENCY #########"
		# else
		# 	echo "ERROR -> FAILED TO DOWNLOAD THE HADOOP DEPENDENCY. THIS MAY LEAD TO UNEXPECTED BEHAVIOR"
		# fi

	fi


	env_variable_exists_checker "$FLINK_HOME" FLINK_HOME=\$HOME/flink
	env_variable_exists_checker "$JAVA_HOME" JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	source /etc/profile
	echo "ENVIRONMENT VARIABLES ACTIVATED"
	sleep 2

	echo "######### START CONFIG SYNC #########"

	rsync -raz --progress Standalone/ $FLINK_HOME/conf/

fi

