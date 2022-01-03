#!/bin/bash -i


# Steps to setup nexmark standalone

# Prerequisites:
# 	Flink installation and $FLINK_HOME defined
# 	Java installation and $JAVA_HOME defined

# Step 1) Copy /nexmark to $HOME (Optional step to keep everything simple)
# Step 2) Copy the contents of /nexmark/lib to /flink/lib (for the generator)
# Step 3) Edit the properties jobmanager.rpc.address, state.checkpoints.dir and state.backend.rocksdb.localdir to match the current machine. It is also adviced to take a look at the memory configs
# Step 4) Copy (and replace) flink-conf.yaml and sql-client-defaults.yaml (found in the directory $FLINK_HOME/conf) with the corresponding files in
# the nexmark/conf
# Step 5) Edit workers file with cluster configs (Found in the folder $FLINK_HOME/conf)
# Step 6) Edit nexmark.yaml file (Found in the nexmark/conf/)

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

source_option='false'
NEXMARK_MASTER=""
NEXMARK_WORKERS=""

if [ $# -eq 0 ]
then
	echo "######### DEFAULT BEHAVIOR. #########"

else

	while test $# -gt 0; do
	  case "$1" in
	    -h|--help)
	      echo "options:"
	      echo "-h, --help                	show brief help"
	      echo "-s, --source		  	Build from sources flag. "
	      echo "-w, --workers		  		Specify the comma delimitered IPs for the Flink worker nodes (Non-Optional parameter)"
	      echo "-m, --master		  		Specify the IP for the Flink master node (Non-Optional parameter)"
	      exit 0
	      ;;
	    -s|--source)
	      shift
	      source_option='true'
	      ;;
	    -w|--workers)
	      shift

	      if test $# -gt 0; then
	        NEXMARK_WORKERS=$1
	        echo "######### NEXMARK_WORKERS -> ${NEXMARK_WORKERS} #########"
	      fi
	      shift
	      ;;
	    -m|--master)
	      shift
	      if test $# -gt 0; then
	        NEXMARK_MASTER=$1
	        echo "######### NEXMARK_MASTER -> ${NEXMARK_MASTER} #########"
	      fi
	      shift
	      ;;
	    *)
	      break
	      ;;
	  esac
	done
fi

# If either of flink master and workers are not defined exit
if [[ -z $NEXMARK_WORKERS || -z $NEXMARK_MASTER ]]; then
	echo "######### BOTH NEXMARK MASTER AND WORKERS MUST BE SPECIFIED. EXITING.... "
	exit -1
fi



# CHECK THE PREREQUISITES STEP -> In case flink is built from source then change the default flink home path
if [ "$source_option" = true ] ; then
	env_variable_exists_checker "$FLINK_HOME" FLINK_HOME=\$HOME/flink/build-target
else
	env_variable_exists_checker "$FLINK_HOME" FLINK_HOME=\$HOME/flink
fi


# Check JAVA_HOME path
env_variable_exists_checker "$JAVA_HOME" JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Apply changes in order to avoid other issues
source /etc/profile



# Step 1
rsync -raz --progress nexmark/ $HOME/nexmark

# Step 2
rsync -raz --progress $HOME/nexmark/lib/ $FLINK_HOME/lib

# Step 3. For now it is easier to just create a folder in $HOME directory
sed -i "s+^state.checkpoints.dir:.*+state.checkpoints.dir: file://$HOME/checkpoint/state+g" $HOME/nexmark/conf/flink-conf.yaml
sed -i "s+^state.backend.rocksdb.localdir:.*+state.backend.rocksdb.localdir: $HOME/checkpoint/rocksdb+g" $HOME/nexmark/conf/flink-conf.yaml
# sed -i "s+^jobmanager.rpc.address:.*+jobmanager.rpc.address: $NEXMARK_MASTER" $HOME/nexmark/conf/flink-conf.yaml

# Step 4
rsync -raz --progress $HOME/nexmark/conf/flink-conf.yaml $FLINK_HOME/conf

rsync -raz --progress $HOME/nexmark/conf/sql-client-defaults.yaml $FLINK_HOME/conf

# Step 5
# sed -i "s+^localhost++g" $FLINK_HOME/conf/workers

# Loop the Worker IP's
# for i in $(echo $NEXMARK_WORKERS | tr "," "\n")
# do
# 	# process
# 	echo ${i} >> $FLINK_HOME/conf/workers
# done

# Step 6

sed -i "s+^<value>nexmark.metric.reporter.host:.*</value>+<value>nexmark.metric.reporter.host: $NEXMARK_MASTER</value>" $HOME/nexmark/conf/nexmark.yaml
