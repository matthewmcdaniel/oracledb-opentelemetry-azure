# Oracle Autonomous Database at Azure

## Introduction

Learn about monitoring Oracle Database@Azure using Cloud Native tools such as Prometheus and Grafana.

Oracle Database@Azure is an Oracle Cloud Database service that runs Oracle Database workloads in your Azure environment. All hardware for Oracle Database@Azure is colocated in Azure's data centers and uses Azure networking. The service benefits from the simplicity, security, and low latency of a single operating environment within Azure. Federated identity and access management for Oracle Database@Azure is provided by Microsoft Entra ID.

The above introduction was sourced from [here](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/oaa.htm)

In this Workshop, we’ll explore the following:

* Deploy a Serverless Autonomous Database (ADB-S) Instance from the Azure Portal
* Deploy Prometheus and Grafana.
* Deploy Oracle Database Prometheus exporter.
* Import and view dashboards in grafana. 

## Documentation 

<https://www.oracle.com/cloud/azure/oracle-database-at-azure/>

<https://azuremarketplace.microsoft.com/en-us/marketplace/apps/oracle.oracle_database_at_azure?tab=Overview>

<https://docs.oracle.com/en-us/iaas/Content/database-at-azure/oaa.htm>

<https://github.com/iamseth/oracledb_exporter>

## Task 1: Provision ADB-S via Azure Portal and Download Wallet

<https://learn.microsoft.com/en-us/azure/oracle/oracle-db/oracle-database-provision-autonomous-database>

<https://docs.oracle.com/en-us/iaas/Content/database-at-azure-autonomous/odadb-provisioning-autonomous-database-azure.html>

1. Log Into Azure Portal

    <https://portal.azure.com/>
    
2. Click on All Services, Databases, Oracle Database@Azure

    ![All Services](images/azure/all_services.png)

3. Click on Create an Oracle Autonomous Database

    ![Oracle Databases](images/azure/oracle_database.png)

4. Select Subscription and Resource Group, Enter a Name and Select a Region

    ![Name and Region](images/azure/name_region.png)

5. Select Workload Type, Database Version and Enter Admin Password

    ![Workload Version and Password](images/azure/workload_version.png)

6. Accept the Defaults for Networking

    ![Networking](images/azure/networking.png)

7. Accept the Defaults for Maintenance

    ![Maintenance](images/azure/maintenance.png)

8. Accept Defaults for Consent

    ![Consent](images/azure/consent.png)

9. Accept Default for Tags

    ![Tags](images/azure/tags.png)

10. Click Create at Review + Create

    ![Review and Create](images/azure/review_create.png)

11. The Deployment is **in progress**

    ![Deployment In Progress](images/azure/deploy_in_progress.png)

12. The Deployment is **complete**, Click Go to Resource

    ![Deployment Complete](images/azure/deploy_complete.png)

13. Select the Autonomous Database you just created

    ![Select Resource](images/azure/select_adb.png)

14. Here you can click on **Connections** to Download the Wallet and **Go to OCI** 

    ![Connections](images/azure/click_connections.png)

15. Click on Download Wallet

    ![Download Wallet](images/azure/download_wallet.png)

16. Enter a password and Click Download

    ![Wallet Password](images/azure/wallet_password.png)
    
17. Copy Wallet Zip File to Desired Location and Unzip it (e.g.,            C:\\adbs\_at\_azure\\adb_wallets\\)

    ![Wallet Unzipped](images/azure/wallet_unzip.png)

## Task 2: Download Prometheus and Grafana

1. This lab assumes you already have a have an AKS cluster.

2. Download kube-prometheus, which includes Grafana: https://github.com/prometheus-operator/kube-prometheus

    ```
    git clone https://github.com/prometheus-operator/kube-prometheus
    ```
    ```
    kubectl apply --server-side -f manifests/setup kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring
    kubectl apply -f manifests/
    ```

## Task 4: Download Oracle DB Prometheus Exporter

1. Go to https://github.com/oracle/oracle-db-appdev-monitoring

2. Create K8s secret for your DB user/password
    ```
    kubectl create secret generic db-secret \
        --from-literal=username=pdbadmin \
        --from-literal=password=Welcome12345 \
        -n exporter
    ```

3. Apply metrics-exporter-config

    ```
    kubectl create cm metrics-exporter-config \
    --from-file=metrics-exporter-config.yaml
    ```

4. Create a configmap for your wallet

    ```
    kubectl create cm db-metrics-tns-admin \
        --from-file=cwallet.sso \
        --from-file=ewallet.p12 \
        --from-file=ewallet.pem \
        --from-file=keystore.jks \
        --from-file=ojdbc.properties \
        --from-file=sqlnet.ora \
        --from-file=tnsnames.ora \
        --from-file=truststore.jks \
        -n exporter
    ```

5. Modify `kubernetes/metrics-exporter-deployment.yaml` to include your TNS name in the `DB_CONNECT_STRING` environment variable.

    ```
    - name: DB_CONNECT_STRING
            value: "DEVDB_TP?TNS_ADMIN=$(TNS_ADMIN)"
    ```
    replace `value` with the TNS name of your choosing, you can find the TNS name in the `tnsnames.ora` file that is included in your wallet. For example
    ```
    - name: DB_CONNECT_STRING
            value: "adbatazure_low"
    ```

6. Modify the `DIRECTORY` parameter in your `sqlnet.ora` file to correspond to location the wallet will be mounted at in the exporter pod. The directory location should be `/oracle/tns_admin` or you can replace your `sqlnet.ora` 

    ```
    WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/oracle/tns_admin")))
    SSL_SERVER_DN_MATCH=yes
    ```

7. Deploy exporter deployment

    ```
    kubectl apply -f metrics-exporter-deployment.yaml
    ```

8. Deploy exporter service

    ```
    kubectl apply -f metrics-exporter-service.yaml
    ```
9. Deploy Prometheus service monitor

    ```
    kubectl apply -f metrics-service-monitor.yaml
    ```

## Task 3: Import Grafana Dashboards

1. (Optional) Create `Load Balancer` service for Grafana.

    ```
    apiVersion: v1
    kind: Service
    metadata:
    name: grafana-lb-service
    spec:
        type: LoadBalancer
        ports:
        - port: 3000
        selector:
            app.kubernetes.io/component: grafana
    ```

2. Access Grafana using load balancer IP address. To find the IP, run the following command.

    ```
    kubectl get svc grafana-lb-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    ```

3. In a web browser, access grafana using the public IP and its port (3000).

    ```
    http://<public-ip>:3000/
    ```

4. In the top-right, click `Import Dashboard`.

5. In the `oracle-db-appdev-monitoring/docker-compose/grafana
/dashboards/` directory of the Oracle DB Prometheus exporter Git repository, copy the contents of `oracle-rev3.json` and paste in the `Import via dashboard JSON model` box in Grafana.

5. Click `Load`.

6. You can now access the Oracle Dashboard in Grafana!

    ![Alt text](image.png)

