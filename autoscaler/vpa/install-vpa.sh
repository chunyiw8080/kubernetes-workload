#!/bin/bash

git clone https://github.com/kubernetes/autoscaler.git

./autoscaler/vpa/autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

sleep 5

echo "===> VPA Pods <==="
kubectl get pods -n kube-system | grep vpa