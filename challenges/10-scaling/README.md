# Scaling

## Expected outcome

In this lab you will use both imperative and declarative methods to scale a ReplicaSet or Deployment. You will then learn to use the Horizontal Pod Autoscaler `hpa` to leverage heapster based metrics to scale a deployment. 

## How to

1. Deploy the kaur application 

    Use evillgenius/kuar:1, create a deployment with the service exposed on port 80 and 2 replicas.

    ```sh
    kubectl create -f config\scaleapp.yaml
    ```

    [Example](config/scaleapp.yaml)

    Wait for the service to spin up and verify it is publicly accessible by going to the public IP in a browser.

2. Scale the deployment

    Scale the deployment to 4
    ```sh
    kubectl scale --replicas=4 --namespace=my-ns deployment/my-deploy
    ```

    While using the `kubectl scale` command is good for emergency type situations or one off scaling. In a declarative world, we make changes by editing the manifest file directly then applying the changes to the api:

    ```yaml
    ...
    spec:
    replicas: 4
    ...
    ```
    
    Apply the original changes to scale the replica's back to 2
    ```sh
    kubectl apply -f config\scaleapp.yaml
    ```

3. Autoscale

    Set the Horizontal Pod Autoscaler to scale the deployment based on cpu. 
    Use the `kubectl autoscale deploy` with a min, max and cpu-percent options to scale the service based on cpu usage above 80%. 
    Set the minimum pods as 5 and max as 10. 

    ```sh
    kubectl autoscale deployment my-deploy --namespace=my-ns --min=5 --max=10 --cpu-percent=80
    ```

    Get the status of the autoscaler.
    ```sh
    kubectl get hpa --namespace=my-ns
    ```

4. Clean Up

    ```sh
    kubectl delete -f config\scaleapp.yaml
    ```

## Advanced areas to explore

1. Take a look scaling nodes in AKS.