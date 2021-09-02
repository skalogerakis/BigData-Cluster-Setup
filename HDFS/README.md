# Executing the scripts

## hdfs-standalone.sh

###  Script parameters

The hdfs-standalone.sh script offers the following CLI parameters

	-h, --help						    Shows brief help
	-hadoop, --hadoop		  	  Specify the Hadoop version to download. Default: hadoop-3.3.1
	-d, --downloaded		  	   Already downloaded binaries flags. (For Config sync).

	
### Executing the script

An execution example of the script is the following

	./hdfs-standalone.sh 

This example is used when setting up a standalone cluster with the default script options.

### Default behavior

The script was primarily designed to automatically setup HDFS standalone cluster from scratch on a new machine(or VM). For that reason, the script downloads the binaries from the official hadoop website, sets required environment variables for the environment and allows necessary changes to the config files.

Different config files found in the **/Standalone** directory contain the necessary changes to get the system up and running with no error. Even after the initial execution the **-d, --downloaded** flag allows to apply additional changes to the configurations in the **Standalone** dir that are applied directly to the cluster configurations


## hdfs-cluster.sh


###  Script parameters

The hdfs-cluster.sh script offers the following CLI parameters

	-h, --help						    Shows brief help
	-hadoop, --hadoop		  	  Specify the Hadoop version to download. Default: hadoop-3.3.1
	-d, --downloaded		  	  Already downloaded binaries flags. (For Config sync).
	-w, --workers		  				Specify the comma delimitered IPs for the Hadoop worker nodes (Non-Optional parameter)
	-m, --master		  				Specify the IP for the Hadoop master node (Non-Optional parameter)

	
### Executing the script

An execution example of the script is the following

	./hdfs-cluster.sh -m 12.456.789.123 -w 99.999.999.999,88.888.888.888

This example is used when setting up a cluster with one master node with IP 12.456.789.123 and two worker nodes withIPs 99.999.999.999 and 88.888.888.888

### Default behavior

The script was primarily designed to automatically setup a cluster from scratch on a new machines(or VMs). For that reason, the script downloads the binaries from the official hadoop website, sets required environment variables for the environment and allows necessary changes to the config files.

Different config files found in the **/Cluster** directory contain the necessary changes to get the system up and running with no error. Even after the initial execution the **-d, --downloaded** flag allows to apply additional changes to the configurations in the **Cluster** dir that are applied directly to the cluster configurations

_NOTE: It is required to execute the script with the same arguments in all the machines that are part of the cluster so that the same configurations take effect on all machines. It is also obligatory to define the master and workers parameters otherwise an error message will show up_

# HDFS Installation

## Prerequisites

The following requirements must be met at each machine on both standalone and cluster versions 

- Debian-based Linux OS
- Java 8 or 11
- ssh (sshd must be running to manage remote components)

It is also advised to keep the same directory structure across all different machines to make troubleshooting easier.

_NOTE: Before executing the desired script check the readme files in the corresponding folders to check for special requirements in each mode_

### Installing Java

To checke whether java is installed in the system type the command **java -version**. If Java is not installed the simplest way to install is by executing the command

    sudo apt-get install openjdk-8-jdk

