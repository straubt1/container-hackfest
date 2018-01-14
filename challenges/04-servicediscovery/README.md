# Service Discovery and Networking

## Expected outcome

In this lab you should be able to identify how Pods communicate between each other in a cluster and discover other services within different namespaces. At first you will use 2 utility containers to easily identify how DNS Service discovery is resolved within a Pod and then you will deploy a small 2-tier application that uses a web application and a datastore in separate pods that need to talk to each other.

## How to

1. Deploy __Service1__

	* _name_: service1
    * _image_ = evillgenius/kuar:1
    * Exposes port 8080
	* Single replica
	* Public IP Address

	[Example](config/service1.yaml)

2. Deploy __Service2__

	* _name_: service2
    * _image_ = evillgenius/kuar:1
    * Exposes port 8080
	* Single replica
	* Public IP Address

	[Example](config/service1.yaml)

3. Verify public connection to both services

	http://<Public IP - Service1>:8080/

	http://<Public IP - Service2>:8080/

4. Verify __Service1__ can communictate with __Service2__

	Click on the _DNS Query_ tab in __Service1__, query for "service2"
	Click on the _DNS Query_ tab in __Service2__, query for "service1"

	Ensure you get a record back similar to the following for each DNS Query:
	```
	;; ANSWER SECTION:
	service2.default.svc.cluster.local.	29	IN	A	10.0.73.4
	```

5. Clean Up

	

## Advanced areas to explore

1. Deploy another version of the service to a different Namespace and investigate how the DNS changes.
2. Investigate a kubernetes Incubator project called [externalDNS](https://github.com/kubernetes-incubator/external-dns) to automatically deploy AzureDNS for Services exposed through the ALB.
