# Helm

## Expected outcome

In this lab we will setup Helm and package, deploy, and update applications. Helm is a "package manager" for Kubernetes. Read more about Helm here: https://docs.helm.sh 

## How to

1. Install Helm
    
    To install Helm in your kubernetes cluster run the following which will configure the cluster
    ```sh
    > helm init

    ...

    Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.
    Happy Helming!
    ```

    Verify by checking the version which will return client and server information
    ```sh
    > helm version
    Client: &version.Version{SemVer:"v2.7.2", GitCommit:"8478fb4fc723885b155c924d1c8c410b7a9444e6", GitTreeState:"clean"}
    Server: &version.Version{SemVer:"v2.7.2", GitCommit:"8478fb4fc723885b155c924d1c8c410b7a9444e6", GitTreeState:"clean"}
    ```

    More information on Helm here. https://docs.helm.sh/using_helm/#installing-helm 

2. Create charts

    Use the sample "Microsmack" application to create a new helm installation. https://github.com/chzbrgr71/microsmack
    ```sh
    helm create microsmack
    ```

    To debug your chart you can use the following to see what will be created:
    ```sh
    helm install --dry-run --debug --name test-microsmack --namespace micro-ns microsmack
    ```

    You can use this article as a guide: https://www.influxdata.com/blog/packaged-kubernetes-deployments-writing-helm-chart 

    [Example Microsmack Charts](https://github.com/chzbrgr71/microsmack/tree/master/charts)

3. Deploy your apps using Helm and the charts from step 2

    Install
    ```sh
    helm install --name my-microsmack --namespace my-ns ./microsmack/
    ```

    Get Status
    ```sh
    helm status my-microsmack
    ```

4. Update, Release, Rollback

    ```sh
    helm upgrade my-microsmack .
    helm history my-microsmack
    helm rollback my-microsmack 1
    ```

    You can use this article as a guide: https://docs.bitnami.com/kubernetes/how-to/deploy-application-kubernetes-helm/

5. Delete application

    ```sh
    helm delete my-microsmack-***-***
    ```

## Advanced areas to explore

1. Helm tests
2. Draft
3. Chart repositories