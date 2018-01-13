# CI/CD

## Expected outcome

In this challenge, you will create a workflow for continuous integration and continuous delivery into ACS Kubernetes. This will include automation steps in Jenkins for building/testing an app, creating containers, pushing to a private registry, and finally updating the app into Kubernetes.

## How to

### Github Repository

1. Fork this repo into your Github account. https://github.com/chzbrgr71/microsmack 
2. Clone your forked copy to your local machine.
3. Replace the contents of jenkins-values.yaml with the details from the file in the [jenkins-values.yaml](config/jenkins-values.yaml)
4. In your terminal window, change to the directory where you have cloned the repo.

### Jenkins Setup (via Helm)

1. Review the "jenkins-values.yaml" from above

2. Install Jenkins

    ```
    helm --namespace jenkins --name jenkins -f ./config/jenkins-values.yaml install stable/jenkins

    helm status jenkins
    ```
    __Note:__ It may take a couple minutes for the UI of jenkins to be available and you may see persistent volume errors in the cluster until the volumes are created.

3. When pod is running, get Jenkins username and password

    ```
    kubectl get secret --namespace jenkins jenkins-jenkins -o jsonpath="{.data.jenkins-admin-user}" | base64 --decode
    kubectl get secret --namespace jenkins jenkins-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
    ```

4. Get the external IP address of your Jenkins service and browse to the IP

    ```
    export SERVICE_IP=$(kubectl get svc jenkins-jenkins --namespace=jenkins -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

    echo http://$SERVICE_IP:8080/login
    ```

5. Update Jenkins

    Jenkins may already be up to date, ensure it is version `2.89.2+`, the version can be found at the bottom right of any page.

    Update all the plugins and allow Jenkins to restart.

6. Configure Jenkins

    Create credentials for Jenkins to authenticate to you ACR instance.
    * Credentials > Jenkins > Global credentials > Add Credentials
        http://<PUBLIC IP>:8080/credentials/store/system/domain/_/newCredentials
    * Username with password
    * ID = acr_creds
    * Description = acr_creds

    Configure Kubernetes on Jenkins
    * Jenkins > Manage Jenkins > Configure System
        http://<PUBLIC IP>:8080/configure
    * "Add Cloud" > Kuberenetes
        Insert the Kubernetes URL, example: `https://***-kubernetes-***-***.hcp.centralus.azmk8s.io`

7. Update your repo
    
    In your fork of microsmack update the Jenkinsfile with your repo name, acr server, etc...
    ```
    def repo = "<YOUR REPO NAME>"
    def appMajorVersion = "1.0"
    def acrServer = "<YOUR ACR NAME>.azurecr.io"
    def acrJenkinsCreds = "acr_creds" //this is set in Jenkins global credentials
    ```

### Setup Application

1. Deploy initial version of app (Microsmack web and api)

    ```
    kubectl create -f kube-api.yaml
    kubectl create -f kube-web.yaml
    ```

### Jenkins Pipeline Setup

1. Create a Pipeline

    New Item > Pipeline and give it a name > Ok

    In the Pipeline section, "Pipeline script from SCM"
    * Git SCM
    * Enter URL of your forked repo, should be public so no credentials needed
    * Build master
    * Script Path -> "Jenkinsfile"
    * Save

2. Run the Pipeline

    Click "Open Blue Ocean" -> "Run".
    Once the agents are created in your cluster, the build will begin.
    
    The Jenkinsfile performs the following actions:        
        * Add a stage for Golang build and test
        * Add a stage to create Docker containers and push to ACR
        * Add a stage to update kube deployments with new image tag

3. Update code and ensure pipeline deploys new version of app

4. Setup webhook to fire pipeline on code change

    Poll SCM -> "* * * * *" will poll every minute

> Note: It is possible to use a Kubernetes plug-in for Jenkins. At the time of this writing the plug-in had some bugs but has since been released. https://plugins.jenkins.io/kubernetes-cd 


## Advanced areas to explore

1. Build in steps to handle PR's and dev branches
2. Add a step to security scan images
3. Blue/green Deployment. https://www.ianlewis.org/en/bluegreen-deployments-kubernetes 
3. Spinnaker