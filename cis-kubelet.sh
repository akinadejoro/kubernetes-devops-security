#!/bin/bash
#cis-kubelet.sh

# sudo chmod 777 /var/lib/etcd/
# echo $(id -u):$(id -g)

# total_fail=$(kube-bench run --targets node  --version 1.20 --check 4.2.1,4.2.2 --json | jq .Totals.total_fail)
total_fail=`kube-bench run --targets node  --version 1.20 --check 4.2.1,4.2.2 --json | jq .Totals.total_fail`
echo $total_fail

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed Kubelet while testing for 4.2.1, 4.2.2"
                exit 1;
        else
                echo "CIS Benchmark Passed Kubelet for 4.2.1, 4.2.2"
fi;