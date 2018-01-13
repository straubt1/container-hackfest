# Persistent Storage

## Expected outcome

In this lab you will use Kubernetes Persistent Storage constructs to mount a persistant volume store for a container. This exercise will use the Dynamic method instead of a static Persistent Volume 

## How to

1. Create a Storage Class named `azuredsc`

    Create a storage class. Please use storage.k8s.io/v1beta1. You can see the spec in [here](https://github.com/kubernetes/kubernetes/blob/master/docs/api-reference/storage.k8s.io/v1beta1/definitions.html)

    If you created the cluster with managed disks you must use `managed` as the StorageClass kind. If your Agents are using Storage Accounts for DataDisks then you must use `shared` as the StorageClass kind.

    [Example](config/storage-class.yaml)

    Deploy:
    ```
    kubectl create -f config\storage-class.yaml
    ```

2. Create the Persistent Volume Claim named `mssql-pv-claim`

    Create a Persistent Volume Claim definition. You need to specify `storageClassName` on specification.
    
    [Example](config/pv-claim.yaml)

    Deploy:
    ```
    kubectl create -f config\pv-claim.yaml
    ```

3. Deploy the `microsoft/mssql-server-linux` container.

    * Run with the volume `/var/opt/mssql` mounted from the PersistentVolumeClaim you created. 
    * The mssql container requires 3 environment variables; 
        * `ACCEPT_EULA` with a value of `Y`
        * `MSSQL_SA_PASSWORD` with a value of a complex password of at least 8 characters including uppercase, lowercase letters, base-10 digits and/or non-alphanumeric symbols
        * `MSSQL_PID` with a value of `Developer`

    [Example](config/mssql-store.yaml)

    Deploy:
    ```
    kubectl create -f config\mssql-store.yaml
    ```     

4. Use ``sqlcmd`` to create a new database and a new table and insert some data into the table.

     `exec` into the container by locating the pod name that mssql-deploy created

    ```sh
    $ kubectl exec mssql-store-***-*** -it bash
    root@mssql-store-***-***:/#
    ```

Not the public IP
/opt/mssql-tools/bin/sqlcmd -S 10.0.66.232,1433 -U SA -P 'My_Complex_Pass1'
    * Go to the bash shell of your mssql pod
    * Connect to your service instance on port 1433
        * `/opt/mssql-tools/bin/sqlcmd -S <IP_OF_SERVICE>,1433 -U SA -P '<YourPassword>'`
    * At the sqlcmd prompt create a new database
        * `CREATE DATABASE TestDB`
    * Verify the table was created
        * `SELECT Name from sys.Databases`
    * Execute the above commands
        * `GO`
    * Set the DB context and create a new table called Inventory
        * `USE TestDB`
        * `CREATE TABLE Inventory (id INT, name NVARCHAR(50), quantity INT)`
        * `GO`
    * Insert data into the new table 
        * `INSERT INTO Inventory VALUES (1, 'penguins', 150); INSERT INTO Inventory VALUES (2, 'whales', 154);`
        * `GO`
    * Query the table to verify the data was written
        * `SELECT * FROM Inventory WHERE quantity > 152;`
        * `GO`
    * Exit the `sqlcmd` tool
        * `QUIT`
    * Exit your shell session by typing `exit`

5. Determine the node the msqql pod is running on and drain the node. You may have to use ``--ignore-daemonsets`` parameter to properly drain the node.

    ```
    kubectl get node

    kubectl drain aks-nodepool1-***-* --ignore-daemonsets --delete-local-data
    ```

    Once the node is showing no errors
    ```
    kubectl uncordon aks-nodepool1-***-*
    ```

6. Verify that the new pod can access the data written by the old pod.

    Use `kubcetl get all` to determine when the pod is finished recreating. 
    
    Once the new pod is in a running state on a new node, connect to the database and query the Inventory table again to verify the data persisted.


## Advanced areas to explore

1. Try make a similar claim using AzureFiles.
2. Use secrets to store the mssql credentials

## Notes

* In the drain pod step, if jenkins is still running from the previous challenge, it's local data will be lost.
