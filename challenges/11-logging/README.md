# Monitoring and Logging

## Expected outcome

In this lab you will setup centralized logging and/or monitoring solutions for your ACS Kubernetes cluster.

## How to


1. Elasticsearch

	https://github.com/kubernetes/examples/tree/master/staging/elasticsearch
	https://github.com/pires/kubernetes-elasticsearch-cluster

	

	Create the resources needed.
	```sh
	kubectl create -f config/service-account.yaml
	kubectl create -f config/es-svc.yaml
	kubectl create -f config/es-rc.yaml
	```

	Get the service, namely its public IP (this may take a few minutes to appear)
	```sh
	kubectl get service elasticsearch
	```


	```sh
	kubectl create -f config/kibana.yaml
	kubectl create -f config/kibana-svc.yaml
	```

	Get the service, namely its public IP (this may take a few minutes to appear)
	```sh
	kubectl get service kibana
	```



Follow one or more of the below guides.

* Operations Management Suite (OMS). https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-oms

* Datadog. https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-datadog 

* Sysdig. https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-sysdig

* CoScale. https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-coscale 
    
* fluentd, elastic search, and kibana

* Monioring with Prometheus and Grafana

* Splunk

## Notes

- This does not seem to be supported yet in AKS.

