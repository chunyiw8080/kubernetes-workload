# Dependencies for HPA

1. Install Metrics Server
2. Update kube-apiserver manifest(/etc/kubernetes/manifests/kube-apiserver.yaml), add ``--enable-aggregator-routing=true`` under the ``command`` field.

