#!/bin/bash
#cis-etcd.sh

# sudo chmod 777 /var/lib/etcd/
# echo $(id -u):$(id -g)

# total_fail=$(kube-bench run --targets etcd --version 1.20 --check 2.2 --json | jq .Totals.total_fail)
kube-bench run --targets etcd --version 1.20 --check 2.2 --json | jq .Totals.total_pass

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed ETCD while testing for 2.2"
                exit 1;
        else
                echo "CIS Benchmark Passed for ETCD - 2.2"
fi;