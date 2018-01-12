# Kubernetes Basics (Pods, Deployments, Services, Namespaces, Health Checks)

## Expected outcome

In this lab you will deploy some basic kubernetes resources for a sample application.

## How to

1. Create a __Pod__ manifest file (`pod.yaml`) that has the following parameters
    * _name_: my-pod
    * Uses 2 Labels 
        * _zone_ = prod
        * _version_ = v1
    * _image_ = evillgenius/kuar:1
    * Exposes port 8080

    [Example](config/pod.yaml)

2. Deploy the __Pod__ manifest

    Execute the manifest file: `kubectl create -f config\pod.yaml`
    
    Expose the Pod by port forwarding: `kubectl port-forward my-pod 8080:8080` (will run in the background)

    Verify the the endpoint locally: `http://localhost:8080`

    Stop the port forwarding command.

3. Create a __Deploy__ manifest file (`deploy.yaml`) using the same parameters as above but add
    * Create 3 replicas of the app
    * Use a RollingUpdate strategy _maxUnavailable_ = 1 and _maxSurge_ = 1

    [Example](config/deploy.yaml)

4. Deploy the __Deploy__ manifest

    Execute the manifest file: `kubectl create -f config\deploy.yaml`

    Expose the Pod by port forwarding: `kubectl port-forward my-pod 8080:8080` (will run in the background)

    Verify the the endpoint locally: `http://localhost:8080`

    Stop the port forwarding command (_Control + c_)

5. Create a __Service__ manifest file (`service.yaml`) that exposes the container using a LoadBalancer

    [Example](config/service.yaml) 

6. Deploy the __Service__ manifest

    Execute the manifest file: `kubectl create -f config\service.yaml`

    > **Note:** Creating a public endpoint can take up to a few minutes.
        You can run `kubectl get service -w` until an external IP is shown. You will also be able to view the public IP from the portal.
    
    Verify the the endpoint publicly: http://<Public IP>:8080/    

7. Clean Up
    ```
    kubectl delete pods,deployments,services,namespaces --all
    ```
    **Note:** some namespaces can not be deleted, and the kubernetes service should restart automatically.


8. Create an __App__ manifest file (`myhealthyapp.yaml') that combines the __Deploy__ and __Service__ manifests and adds Health Checks

    Add:
    * The kuar app has an http /healthy path listening on port 8080 for Liveness
    * The kuar app has an http /ready path listening on port 8080 for Readiness

    [Example](config/myhealthyapp.yaml)

9. Deploy the __App__ manifest

    Execute the manifest file: `kubectl create -f config\myhealthyapp.yaml`

    Check the status: `kubectl get service my-healthysvc`, eventually it will show an external IP
        this didnt work for me, didnt show in services?? had to go to the portal to get the IP

    Verify the the endpoint publicly: http://<Public IP>:8080/

    Navigate to the liveness and readiness pages: http://<Public IP>:8080/-/liveness & http://<Public IP>:8080/-/readiness

    Open the K8S cluster and monitor failures as you experiment with sending failures

10. Clean Up again


## Advanced areas to explore

1. Deploy a Pod that has multiple containers in a single Pod.
2. Change the image version of your deployment and cause a RollingUpdate.
3. Rollback an update
