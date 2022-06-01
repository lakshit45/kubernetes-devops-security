#!/bin/bash
#cis-kubelet.sh

total_fail=$( sudo ./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml run --targets etcd  --version 1.15 --check 2.2 )

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed Kubelet while testing for 4.2.1, 4.2.2"
                exit 1;
        else
                echo "CIS Benchmark Passed Kubelet for 4.2.1, 4.2.2"
fi;
