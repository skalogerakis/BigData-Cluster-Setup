# Flink Standalone Cluster 

## Prerequisites


## Instructions for manual installation

- Step 1) Download the desired Flink package from the [download page](https://flink.apache.org/downloads.html). Another option is to use the **wget <download_link>** command to download directly via CLI. For Flink version 1.12.2 with scala 2.12 the downloaded file will be **flink-1.12.2-bin-scala_2.12.tgz**
- Step 2) Untar the downloaded file 
        
        **tar -xzf flink-1.12.2-bin-scala_2.12.tgz**
- Step 3) Optionally, change the name of the extracted folder to make things easier using the command 
        
        **mv flink-<version> flink**
- Step 4) Ready to go! To verify that everything works as expected execute .<flink_path>/bin/start-cluster.sh to initiate a local cluster. The default webUI of Flink is [http://localhost:8081/](http://localhost:8081/)
> NOTE: The **flink-conf.yaml** file that can be found in the <flink_path>/conf/ directory is responsible for the configurations in the cluster. By default configurations can deploy the cluster successfully, however it is highly recommended to modify the property **taskmanager.numberOfTaskSlots: 1**. The default configuration does not allow to execute concurrent tasks, or even tasks with parallelization more than 1. So modify it to a higher value, however make sure that there are adequate system resources for that case. In general it is recommended to check memory related configurations in flink-conf.yaml file to match each systems capabilities
