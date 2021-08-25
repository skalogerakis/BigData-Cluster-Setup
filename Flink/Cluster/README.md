# Flink Cluster 

## Prerequisites


## Instructions for manual installation

Execute the following instruction in all the desired machines. It also crucial to keep homogeneity in between different machines, so that it will be possible to keep track of the changes and make troubleshooting easier if required

- Step 1) Download the desired Flink package from the [download page](https://flink.apache.org/downloads.html). Another option is to use the **wget <download_link>** command to download directly via CLI. For Flink version 1.12.2 with scala 2.12 the downloaded file will be **flink-1.12.2-bin-scala_2.12.tgz**
- Step 2) Untar the downloaded file 
        
        tar -xzf flink-1.12.2-bin-scala_2.12.tgz
- Step 3) Optionally, change the name of the extracted folder to make things easier using the command 
        
        mv flink-<version> flink

- Step 4) Modify different configuration files that can be found in the <flink_path>/conf/ 

    - Modify flink-conf.yaml file
    
      Locate **jobmanager.rpc.address: localhost** property and replace with **jobmanager.rpc.address: <My_IPv4>**. Set <My_IPv4> the IPv4 of the desired JobManager IP address
     
    - Modify masters file
    
      Modify **locahost:8081**, to **<My_IPv4>:8081** to match once again the JobManager’s IP.
      
    - Modify workers file
    
      Replace localhost, with the IPv4 address of each worker(Task manager). Each line in workers file should contain only one IP address.

> NOTE: Another property that is highly recommended to modify is the **taskmanager.numberOfTaskSlots: 1**. The default configuration does not allow to execute concurrent tasks, or even tasks with parallelization more than 1. So modify it to a higher value, however make sure that there are adequate system resources for that case. In general it is recommended to check memory related configurations in flink-conf.yaml file to match each systems capabilities

- Step 5) Start the cluster by executing ./<flink_dir>/bin/start-cluster.sh script on the JobManager machine. Then access cluster via webUI and <JobManager_IPv4>:8081
  
## Troubleshooting

In some cases JAVA_HOME environment variable can cause problems if not defined with cluster setup. To check if JAVA_HOME is defined run in the CLI the command 
        
       echo ${JAVA_HOME} 
  
To make sure that JAVA_HOME does not cause any issues, users can add the following property inside the flink-conf.yaml file
  
       env.java.home: <Java_Path> 
  
If installed java-8-openjdk java path can be found in the **/usr/lib/jvm/java-8-openjdk-amd64** directory
