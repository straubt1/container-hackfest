# Ingress Controllers

## Expected outcome

In this lab you will use a Ingress Controller primitive in Kubernetes to route http/https traffic through. Typically, services and pods have IPs only routable by the cluster network. All traffic that ends up at an edge router is either dropped or forwarded elsewhere. An Ingress is a collection of rules that allow inbound connections to reach the cluster services. It can be configured to give services externally-reachable URLs, load balance traffic, terminate SSL, offer name based virtual hosting etc. Users request ingress by POSTing the Ingress resource to the API server. An Ingress controller is responsible for fulfilling the Ingress, usually with a loadbalancer, though it may also configure your edge router or additional frontends to help handle the traffic in an HA manner.

## How to

1. Deploy __default-http-backend__
    
    First we will deploy a default backend service from the image gcr.io/google_containers/defaultbackend.
    This image will serve up a HTTP 404 on the route `/` of the URL if it is not an expected path based on the ingress rules.

    Inspect the Default manfiest file: [default.yaml](config/default.yaml)
    
    Deploy:
    ```
    kubectl create -f config\default.yaml
    ```

2. Deploy __nginx-ingress-svc__ 

    Next we will deploy an nginx ingress controller. 
    Inspect the Ingress manifest file: [ingress.yaml](config/ingress.yaml) with VSCode.
    
    This file has a ReplicationController object which deploys a nginx ingress controller with a single replica, but this can be used to deploy an HA service as well.

    ```
    apiVersion: v1
    kind: ReplicationController
    metadata:
    name: nginx-ingress-controller
    labels:
        app: nginx-ingress-lb
    spec:
    replicas: 1
    selector:
        app: nginx-ingress-lb
    template:
        metadata:
        labels:
            app: nginx-ingress-lb
            name: nginx-ingress-lb
        spec:
        containers:
        - image: gcr.io/google_containers/nginx-ingress-controller:0.8.3
            name: nginx-ingress-lb
            ports:
            - containerPort: 80
            hostPort: 80
            env:
            - name: POD_NAME
                valueFrom:
                fieldRef:
                    fieldPath: metadata.name
            - name: POD_NAMESPACE
                valueFrom:
                fieldRef:
                    fieldPath: metadata.namespace
            args:
            - /nginx-ingress-controller
            - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
    ```
    
    Notice that we pass as an argument to the nginx the name of the default-backend service. This allows nginx to process all non-conforming URLs from the ingress rules to the default-backend service.

    Deploy:
    ```
    kubectl create -f config\ingress.yaml
    ```

3. Deploy __Web App__

    Create a manifest that contains 3 of the following:
    * Deployment using the image `evillgenius/simplehttp:latest`, exposing port 80, single replica, name "webapp{Number}"
    * Service exposing the deployment using a NodePort number higher than 30000, name "webapp{Number}-svc"

    [Example](config/websvc.yaml)

    Deploy:
    ```
    kubectl create -f config\websvc.yaml
    ```


4. Deploy __Ingress Rules__

    Ingress Rules create the configuration for the ingress controller for specified services. The ingress rules use an annotation to tell kubernetes that it should be process by a specific ingress controller type:

    ```yaml
    ...
      metadata:
        annotations:
          kubernetes.io/ingress.class: nginx
    ...
    ```

    Inspect the Ingress Rules manifest file: [ingress-rules.yaml](config/ingress-rules.yaml) with VSCode.

    Edit the host section and enter the External IP address assigned to your nginx-ingress-svc. We will use xip.io so you do not have to register a domain. The format should be www.xxx.xxx.xxx.xxx.xip.io where the x's are the numbers of the IP address.

    ```
        - host: www.<ALB_EXT_IP_ADDRESS>.xip.io
    ```

    Verify that the www.<ALB_EXT_IP_ADDRESS>.xip.io returns to your service from above but entering the address in your browser.

    Deploy:
    ```
    kubectl create -f config\ingress-rules.yaml
    ```


5. Verify __Ingress Rules__ 
    
    Wait a few for the rules to publish and then using a browser navigate to _www.<ALB_EXT_IP_ADDRESS>.xip.io/_. The response should return with from the webapp3 since this is the default path.
    
    Test the other paths from the ingress rules file to verify that the ingress controller is properly doing path based routing.
    * _www.<ALB_EXT_IP_ADDRESS>.xip.io/webapp1_
    * _www.<ALB_EXT_IP_ADDRESS>.xip.io/webapp2_
    * _www.<ALB_EXT_IP_ADDRESS>.xip.io/somethingdifferent_

6. Scale __Web App__

    Navigate to the Replica Set for Web App 3, and scale it to 4

    Back in your browser navigate to _www.<ALB_EXT_IP_ADDRESS>.xip.io/_ but refresh the page quickly. You should see that as a web service gets bursted, requests will be transfered to other instances of web app 3.

7. Clean Up

    `kubectl delete deployments,services,pods,ingresses --all`


## Advanced areas to explore

1. Try deploying an HAProxy ingress controller.
2. If you have your own domain name and can create a wildcard cert try creating a TLS secured site with nginx.
