
#!/bin/bash

rm -rf /tmp/flink*
rm -rf /tmp/hadoop*
rm -rf /tmp/rocksdb*
rm -rf /home/ubuntu/tmp/hadoop*
rm -rf /home/ubuntu/tmp/rocks*
rm -rf /home/ubuntu/tmp/io*

sleep 1
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches "



