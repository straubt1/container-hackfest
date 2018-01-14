# Secrets and ConfigMaps

## Expected outcome

In this lab we will use Secrets and ConfigMaps in Kubernetes to store application configuration settings and secrets needed for external services.

## How to

1. Create a simple ConfigMap

    Inspect the redis config file: [redis-config](config/redis-config)
    There are two settings that describe memory management that we will use in the next step.
    
    and then run:

    ```sh
    # Copy the config map into your cluster
    kubectl create configmap example-redis-config --from-file=./config/redis-config

    # Verify the configmap exists
    kubectl get configmap

    # View the details
    kubectl describe configmap example-redis-config
    ```

2. Create a Redis Pod that utilizes the ConfigMap

    Inspect the redis manifest file: [redis-pod](config/redis-pod.yaml)

    Here we can see the use of the configmap
    ```
    ...
    - name: config
      configMap:
        name: example-redis-config
        items:
        - key: redis-config
          path: redis.conf
    ...
    ```

    Deploy:
    ```
    kubectl create -f config/redis-pod.yaml
    ```

3. Validate Redis

    `exec` into the container to verify the correct values are set:
    ```
    $ kubectl exec -it redis redis-cli
    127.0.0.1:6379> CONFIG GET maxmemory
    1) "maxmemory"
    2) "2097152"
    127.0.0.1:6379> CONFIG GET maxmemory-policy
    1) "maxmemory-policy"
    2) "allkeys-lru"
    ```

4. Update the Microsmack sample web app and replace environment variables with a ConfigMap

5. Create a Secret to the cluster

    Base64 encode values for secret and add them to a [secret](config/secret.yaml) file   
    ```
    echo -n "admin" | base64 | pbcopy
    echo -n "Your@Password" | base64 | pbcopy
    echo -n "secret_key" | base64 | pbcopy
    ```

    Deploy:
    ```
    kubectl create -f config/secret.yaml
    ```

6. Deploy __Postgres DB__

    Inspect the postgres manifest file: [postgres](config/postgres.yaml)
    ```
    ...
    volumes:
    - name: secrets
        secret:
        secretName: postgres-secret
    containers:
    - image: chzbrgr71/postgres:secret
        name: db
        volumeMounts:
        - name: secrets
        mountPath: "/etc/secrets"
        readOnly: true
    ...
    ```
    
    Deploy:
    ```
    kubectl create -f config/postgres.yaml
    ```

7. Verify Secrets

    `exec` into the container
    ```sh
    $ kubectl exec db -it bash
    root@db:/#

    # View the mapped in secrets file
    root@db:/# cat /etc/secrets/secret.yaml
    apiVersion: v1
    kind: Secret
    metadata:
    name: postgres-secret
    type: Opaque
    data:
    password: ***
    username: ***
    secret-key: ***

    # Login to the postgres server and execute some queries
    root@db:/# psql -U admin -W
    Password for user admin:
    psql (9.4.14)
    Type "help" for help.

    admin=#
    CREATE SCHEMA test;
    CREATE TABLE test.test (coltest varchar(20));
    INSERT into test.test (coltest) values ('It works!');
    SELECT * from test.test;

    # Use "\q" to exit psql
    ```
    
8. Clean Up

## Advanced areas to explore

1. Create a secret for an Azure Container Registry. Use "imagePullSecrets" to deploy Pod
2. Use HashiCorp Vault to store/encrypt secrets
