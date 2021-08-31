# Executing the scripts

## flink-standalone.sh

###  Script parameters

The flink-standalone.sh script offers the following CLI parameters

	-h, --help						Shows brief help
	-source, --source 				Build from sources flag
	-flink, --flink 				Specify the Flink version to download. Default: flink-1.13.1
	-scala, --scala					Specify the Scala version. Default: scala_2.12
	-d, --downloaded				Already downloaded binaries flags. (For Config sync).
	
### Executing the script

An execution example of the script is the following

	./flink-standalone.sh --source 

This example is used when setting up standalone cluster from sources. 

### Default behavior

The script was primarily designed to automatically setup flink standalone cluster from scratch on a new machine(or VM). For that reason, the script downloads the binaries from the official flink website, sets required environment variables for the flink environment and allows necessary changes to the config files. In addition, extra dependencies are added to allow Hadoop 3.x version migration.

The **flink-conf.yaml** file in the **/Standalone** dir replaces the existing configuration file in the _$FLINK_HOME/conf_ directory, so any changes in the specific are directly applied on the cluster. Even after the initial execution the **-d, --downloaded** flag allows to apply additional changes to the cluster configurations

### Building from sources

Currently building from sources is not sources is not fully automated via the script. More specifically, the developer must download and build the flink project in the $HOME directory. After following these steps, inside the flink directory a new folder is generated /build-target which is essentially the produced flink environment. The script sets that directory as $FLINK_HOME, downloads the desired dependencies for Hadoop 3.x and sets the configurations from the Standalone directory

## flink-cluster.sh



# Flink Installation

## Prerequisites

The following requirements must be met at each machine on both standalone and cluster versions 

- Debian-based Linux OS
- Java 8 or 11

_NOTE: Before executing the desired script check the readme files in the corresponding folders to check for special requirements in each mode_

### Installing Java

To checke whether java is installed in the system type the command **java -version**. If Java is not installed the simplest way to install is by executing the command

    sudo apt-get install openjdk-8-jdk

