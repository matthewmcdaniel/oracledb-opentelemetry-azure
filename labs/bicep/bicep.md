# Creating an Autonomous Database using Azure Infrastructure-as-Code tools

## Introduction

There are many ways to provision an Autonomous Database@Azure: you can use the console for a seamless, new user friendly experience. For more experienced or those who are more DevOps inclined, you can use IaC (Infrastructure-as-code) tools to provision infrastructure through programming tools, such as the API, CLI, or Terraform. Additionally, Azure offers a user-friendly language called Bicep, which acts as an alternative to ARM templates or Terraform, which can often be challenging to read.

In this workshop, you will earn how to provision Oracle Autonomous Database using a variety of IaC tools. 
## Documentation 

What is Bicep? - https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep
Azure Resource Manager - https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview
Oracle Database@Azure - https://www.oracle.com/cloud/azure/oracle-database-at-azure/
Oracle Autonomous Database@Azure Bicep reference - https://learn.microsoft.com/en-us/azure/templates/oracle.database/autonomousdatabases?pivots=deployment-language-bicep

## Task 1a: Access Azure CLI on local machine

1. This workshop can be run on either your own machine or using the Azure Cloud Shell. If you would like to use cloud shell, proceed to *(Optional) Task 1b: Access Azure Cloud Shell*

2. Click the start menu on your device, type **powershell** and click on the powershell app.

    ![Powershell](images/powershell.png)
    
3. Once powershell is open, click on the arrow next to the current terminal session.

    ![Azure CLI](images/azurecli.png)

4. Select Azure Cloud Shell.

    ![Azure CLI in dropdown](images/azurecloudshell.png)

5. Follow the authentication flow.

    ![Azure Authentication Flow](images/azureauthenticationflow.png)

## (Optional) Task 1b: Access Azure Cloud Shell

## Task 1: Write Bicep code
1. Open a terminal with Azure CLI installed, In this example I will use Azure's Cloud Shell
    ![Azure Cloud Shell](./images/cloudshell.png)

    The shell will open at the bottom of the screen.

    ![Azure Cloud Shell](images/azurecloudshellscreen.png)

2. In the terminal, create a file called main.bicep
    ```
    <copy>
    code main.bicep
    </copy>
    ```

    If prompted to open Classic Cloud Shell, click **confirm**.

    ![Classic Cloud Shell](images/classiccloudshell.png)

    Create **main.bicep**
    ```
    <copy>
    code main.bicep
    </copy>
    ```

3. In this file, paste the following content. Note that you will need to change **location**, **adminPassword**, and **email**. Remove the **<** and **>** signs when replacing the values.

    ```
    <copy>
    resource autonomousDatabases_db_name_resource 'Oracle.Database/autonomousDatabases@2025-03-01' = {
    location: '<location>'
    name: 'testbicepdeployment'
    properties: {
        adminPassword: '<example_password>'
        backupRetentionPeriodInDays: 60
        characterSet: 'AL32UTF8'
        computeCount: 2
        computeModel: 'ECPU'
        customerContacts: [
            {
                email: '<email>'
            }
        ]
        dataStorageSizeInTbs: 1
        dbVersion: '23ai'
        dbWorkload: 'OLTP'
        displayName: 'DisplayName'
        isAutoScalingEnabled: true
        isAutoScalingForStorageEnabled: true
        isLocalDataGuardEnabled: false
        isMtlsConnectionRequired: true
        isPreviewVersionWithServiceTermsAccepted: false
        licenseModel: 'LicenseIncluded'
        localAdgAutoFailoverMaxDataLossLimit: 0
        longTermBackupSchedule: {
            isDisabled: false
            repeatCadence: 'Monthly'
            retentionPeriodInDays: 90
        }
        ncharacterSet: 'AL16UTF16'
        openMode: 'ReadWrite'
        permissionLevel: 'Unrestricted'
        scheduledOperations: {
            dayOfWeek: {
                name: 'Sunday'
            }
        }
        dataBaseType: 'Regular'
        // For remaining properties, see AutonomousDatabaseBaseProperties objects
        }
    }
    </copy>
    ```
    Before we continue, let's discuss what these fields mean.

    `location` - Region the Autonomous Database will be deployed in.

    `name` - Name of the resource.

    `adminPassword` - This is the password of the ADMIN user which is provisioned by default.

    There are restrictions on what this password can contain.
    
    * The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character.

    * The password cannot contain the username.

    * The password cannot be one of the last four passwords used for the same username.

    * The password cannot contain the double quote (") character.

    * The password must not be the same password that is set less than 24 hours ago. 

    `backupRetentionPeriodInDays` - This field determines how long a backup is maintained for the Database, you can choose a value between 1 and 60 (days).

    `characterSet` - Oracle supports most ASCII-based character sets. You can find the list here: https://docs.oracle.com/en/database/oracle/oracle-database/23/nlspg/appendix-A-locale-data.html#GUID-A9E30C27-FD47-4552-B670-F41A95B11405

    Generally `AL32UTF8` is sufficient for most use cases. 

    `computeCount` - Determines the number of CPUs to allocate to this database.

    `computeModel` - An OCPU is defined as the equivalent of one physical core with hyper-threading enabled. In contrast, an ECPU is not explicitly defined in terms of an amount of physical hardware. 

    `customerContacts` - The email address used by Oracle to send notifications regarding databases and infrastructure.

    `dataStorageSizeInTbs` - The amount of storage in Terabytes. Alternatively you can use the field `dataStorageSizeInGbs` but you cannot use both at the same time.

    `dbVersion` - The version of database to use, supported values are `19c` and `23ai`.

    `dbWorkload` - The type of workload this database is designed for. Supported values are         
        `AJD` - Autonomous JSON Database
        `APEX` - APEX database 
        `DW` - Data Warehouse
        `OLTP` - Online Transaction Processing.

    `isAutoScalingEnabled` - Determines if the CPU count will auto scale, up to a maximum of 3x the current CPU count.

    `isAutoScalingForStorageEnabled` - Determines if storage will auto scale, up to 3x the base storage value. 

    `isLocalDataGuardEnabled` - Data Guard is responsible for maintaining and monitoring standby databases to ensure Oracle Databases remain highly available. If this option is enabled, it will create a standy database in the same location. 

    `isMtlsConnectionRequired` - If enabled, it will require clients to use a wallet to access the database. The wallet can be retrieved after the database is provisioned. 

    `isPreviewVersionWithServiceTermsAccepted` - Determines if this database has the capability to use preview versions of ADB. 

    `licenseModel` - If you are bringing your own license, use `BYOL`, else you should use `LicenseIncluded`.

    `localAdgAutoFailoverMaxDataLossLimit` - Determines how much data loss is acceptable until the automatic failover is triggered. 

    `longTermBackupSchedule` - This field is responsible for determining the backup schedule.
        `isDisabled` - Determines if the long-term backup schedule should be deleted.
        `repeatCadence` - How often should backups be taken.
        `retentionPeriodInDays`- how long should the backups be retained (in days).
    `ncharacterSet` - Additional character set to be used in conjunciton with the `characterSet`. You can find a list here: https://docs.oracle.com/en/database/oracle/oracle-database/23/nlspg/supporting-multilingual-databases-with-unicode.html#GUID-AA09A60E-123E-457C-ACE1-89E4634E492C

    `openMode` - This determines what read/write access users should have. Options include `ReadOnly` and `ReadWrite`.

    `permissionLevel` - Determines who should have access to the database. Valid options are 
    
    `Restricted` for `ADMIN` only access.
    `Unrestricted` otherwise.

    `scheduledOperations` - Determines when maintenance operations should be scheduled.
        `dayOfWeek` - The day when maintenance should occur.

4. Press Ctrl + S to save your changes.

5. Execute deployment command
    ```
    <copy>
    az deployment group create --name mm-adb-deployment --resource-group code-innovate --template-file main.bicep
    </copy>
    ```

    **NOTE:** Replace the resource-group argument with your own resource group name.

    ```
        The configuration value of bicep.use_binary_from_path has been set to 'false'.
    /home/matthew/main.bicep(4,9) : Warning decompiler-cleanup: The symbolic name of resource 'autonomousDatabases_adbsatazure_name_resource' appears to have originated from a naming conflict during a decompilation from JSON. Consider renaming it and removing the suffix (using the editor's rename functionality). [https://aka.ms/bicep/linter-diagnostics#decompiler-cleanup]
    /home/matthew/main.bicep(6,20) : Warning use-secure-value-for-secure-inputs: Property 'adminPassword' expects a secure value, but the value provided may not be secure. [https://aka.ms/bicep/linter-diagnostics#use-secure-value-for-secure-inputs]

    {
    "id": "<subscription_id>",
    "location": null,
    "name": "mm-adb-deployment",
    "properties": {
        "correlationId": "1933f202-7724-49ff-b868-e95bfacfef0b",
        "debugSetting": null,
        "dependencies": [],
        "diagnostics": null,
        "duration": "PT3M58.6798133S",
        "error": null,
        "mode": "Incremental",
        "onErrorDeployment": null,
        "outputResources": [
        {
            "id": "/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Oracle.Database/autonomousDatabases/<db_name>",
            "resourceGroup": "<resource_group>"
        }
        ],
        "outputs": null,
        "parameters": null,
        "parametersLink": null,
        "providers": [
        {
            "id": null,
            "namespace": "Oracle.Database",
            "providerAuthorizationConsentState": null,
            "registrationPolicy": null,
            "registrationState": null,
            "resourceTypes": [
            {
                "aliases": null,
                "apiProfiles": null,
                "apiVersions": null,
                "capabilities": null,
                "defaultApiVersion": null,
                "locationMappings": null,
                "locations": [
                "eastus"
                ],
                "properties": null,
                "resourceType": "autonomousDatabases",
                "zoneMappings": null
            }
            ]
        }
        ],
        "provisioningState": "Succeeded",
        "templateHash": "532802357778311532",
        "templateLink": null,
        "timestamp": "2025-07-28T21:07:55.798581+00:00",
        "validatedResources": null,
        "validationLevel": null
    },
    "resourceGroup": "<resource_group>",
    "tags": null,
    "type": "Microsoft.Resources/deployments"
    }
    ```
6. Wait for resources to build.

## Task 2: Validate deployment creation
1. Go into Azure Resource Manager

2. Go to Organization > Resource Groups > (Your resource group)

    ![Resource Group](./images/resourcegroup.png)

3. Go to Settings > Deployments > (your deployment)

    ![Deployment](./images/deployments.png)

4. Validate your deployment has been created.

    ![Completed Deployment](./images/completeddeployment.png)

## Task 3: Create Autonomous Database@Azure using ARM templates

1. Access terminal with Azure CLI installed and configured, in this example I will use Azure Cloud Shell.

2. Create resource group

    ```
    <copy>
    az group create --location eastus --name <example_resource_group>
    </copy>
    ```

    ```
    {
        "id": "/subscriptions/<subscription_id>/resourceGroups/<resource_group>",
        "location": "eastus",
        "managedBy": null,
        "name": "code-innovate-iac",
        "properties": {
            "provisioningState": "Succeeded"
        },
        "tags": null,
        "type": "Microsoft.Resources/resourceGroups"
    }
    ```

3. Create ARM deploy file

    ```
    <copy>
    code azuredeploy.json
    </copy>
    ```

    If prompted to open Classic Cloud Shell, click **confirm**.

    ![Classic Cloud Shell](images/classiccloudshell.png)

    Create the ARM deploy file

    ```
    <copy>
    code azuredeploy.json
    </copy>
    ```

4. Paste the following and change the email field under `customerContacts`

    ```
    <copy>
            {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "resources": [
            {
                "type": "Oracle.Database/autonomousDatabases",
                "apiVersion": "2025-03-01",
                "name": "testdeployment",
                "location": "eastus",
                "properties": {
                    "adminPassword": "Dbatazurepassword098",
                    "backupRetentionPeriodInDays": 60,
                    "characterSet": "AL32UTF8",
                    "computeCount": 2,
                    "computeModel": "ECPU",
                    "customerContacts": [
                    {
                        "email": "<insert_email>"
                    }
                    ],
                    "dataStorageSizeInTbs": 1,
                    "dbVersion": "23ai",
                    "dbWorkload": "DW",
                    "displayName": "DisplayName",
                    "isAutoScalingEnabled": false,
                    "isAutoScalingForStorageEnabled": false,
                    "isLocalDataGuardEnabled": false,
                    "isMtlsConnectionRequired": true,
                    "isPreviewVersionWithServiceTermsAccepted": false,
                    "licenseModel": "LicenseIncluded",
                    "localAdgAutoFailoverMaxDataLossLimit": 0,
                    "longTermBackupSchedule": {
                        "isDisabled": false,
                        "repeatCadence": "Monthly",
                        "retentionPeriodInDays": 90
                    },
                    "ncharacterSet": "AL16UTF16",
                    "openMode": "ReadWrite",
                    "permissionLevel": "Unrestricted",
                    "scheduledOperations": {
                        "dayOfWeek": {
                            "name": "Sunday"
                        }
                    },
                    "dataBaseType": "Regular"
                    // For remaining properties, see AutonomousDatabaseBaseProperties objects
                }
            }
        ]
        }
        </copy>
    ```
    **NOTE**: the configuration above is identical to the Bipec example from earlier. 

5. Create ARM template

    ```
    <copy>
    az deployment group create --name adb-arm-template --resource-group <resource_group> --template-file ./azuredeploy.json
    </copy>
    ```

    ```
    {
        "id": "/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Microsoft.Resources/deployments/adb-arm-template",
        "location": null,
        "name": "adb-arm-template",
        "properties": {
            "correlationId": "2667fd8f-0626-423f-bcea-f5e1cdfc67f6",
            "debugSetting": null,
            "dependencies": [],
            "diagnostics": null,
            "duration": "PT3M41.0271783S",
            "error": null,
            "mode": "Incremental",
            "onErrorDeployment": null,
            "outputResources": [
            {
                "id": "/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Oracle.Database/autonomousDatabases/<db_name>",
                "resourceGroup": "<resource_group>"
            }
            ],
            "outputs": null,
            "parameters": null,
            "parametersLink": null,
            "providers": [
            {
                "id": null,
                "namespace": "Oracle.Database",
                "providerAuthorizationConsentState": null,
                "registrationPolicy": null,
                "registrationState": null,
                "resourceTypes": [
                {
                    "aliases": null,
                    "apiProfiles": null,
                    "apiVersions": null,
                    "capabilities": null,
                    "defaultApiVersion": null,
                    "locationMappings": null,
                    "locations": [
                    "eastus"
                    ],
                    "properties": null,
                    "resourceType": "autonomousDatabases",
                    "zoneMappings": null
                }
                ]
            }
            ],
            "provisioningState": "Succeeded",
            "templateHash": "456352182606238030",
            "templateLink": null,
            "timestamp": "2025-07-28T21:27:42.964708+00:00",
            "validatedResources": null,
            "validationLevel": null
        },
        "resourceGroup": "<resource_group>",
        "tags": null,
        "type": "Microsoft.Resources/deployments"
    }
    ```

6. Validate that the deployment has been created. Go to Resource Groups > Settings > Deployments

    ![Successful ARM template](./images/armtemplate.png)

7. Click on the deployment to validate the database has been created.

    ![Successful ARM deployment](images/successfularmdeployment.png)


## Task 3: Using Terraform to provision Autonomous Database@Azure

1. Open a terminal with access to Terraform. In this example I am using Azure Cloud Shell.

2. Create a file called `main.tf`

3. Create Terraform provider within `main.tf`

    ```
    <copy>
    terraform {
        required_providers {
            azapi = {
            source = "Azure/azapi"
            }
            azurerm = {
            source = "hashicorp/azurerm"
            }
        }
    }
    </copy>
    ```

4. Create `azurerm` provider

    ```
    <copy>
    provider "azurerm" {
        resource_provider_registrations = "none"
        subscription_id = "<subscription_ID"
        features {}
    }
    </copy>
    ```

5. Create resource group data source

    ```
    <copy>
    data "azurerm_resource_group" "resource_group" {
        name = "<resource_group>"
    }
    </copy>
    ```
6. Create Autonomous Database resource

    ```
    <copy>
    resource "azapi_resource" "autonomous_db" {
        type                      = "Oracle.Database/autonomousDatabases@2023-09-01"
        parent_id                 = data.azurerm_resource_group.resource_group.id
        name                      = "testbicepdeployment"
        schema_validation_enabled = false
        
        body = {
            "location" : "eastus",
            "properties" : {
            "displayName" : "DisplayName",
            "computeCount" : 2,
            "dataStorageSizeInTbs" : 1,
            "adminPassword" : "Dbatazurepassword098",
            "dbVersion" : "23ai",
            "licenseModel" : "LicenseIncluded",
            "dataBaseType" : "Regular",
            "computeModel" : "ECPU",
            "dbWorkload" : "DW",
            "permissionLevel" : "Restricted",
        
            "characterSet" : "AL32UTF8",
            "ncharacterSet" : "AL16UTF16",
        
            "isAutoScalingEnabled" : false,
            "isAutoScalingForStorageEnabled" : false,

            "isMtlsConnectionRequired": true,

            }
        }
        response_export_values = ["id", "properties.ocid", "properties"]
    }
    </copy>
    ```
7. Run Terraform init

    ```
    <copy>terraform init</copy>
    Initializing the backend...
    Initializing provider plugins...
    - Finding latest version of azure/azapi...
    - Finding latest version of hashicorp/azurerm...
    - Installing azure/azapi v2.5.0...
    - Installed azure/azapi v2.5.0 (signed by a HashiCorp partner, key ID 6F0B91BDE98478CF)
    - Installing hashicorp/azurerm v4.37.0...
    - Installed hashicorp/azurerm v4.37.0 (signed by HashiCorp)
    Partner and community providers are signed by their developers.
    If you'd like to know more about provider signing, you can read about it here:
    https://developer.hashicorp.com/terraform/cli/plugins/signing
    Terraform has created a lock file .terraform.lock.hcl to record the provider
    selections it made above. Include this file in your version control repository
    so that Terraform can guarantee to make the same selections by default when
    you run "terraform init" in the future.

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

7. Run terraform apply, type `yes` when prompted

    ```
    terraform apply
    ```

    ```
    Terraform will perform the following actions:

    # azapi_resource.autonomous_db will be created
    + resource "azapi_resource" "autonomous_db" {
        + body                      = {
            + location   = "eastus"
            + properties = {
                + adminPassword                  = "Dbatazurepassword098"
                + characterSet                   = "AL32UTF8"
                + computeCount                   = 2
                + computeModel                   = "ECPU"
                + dataBaseType                   = "Regular"
                + dataStorageSizeInTbs           = 1
                + dbVersion                      = "23ai"
                + dbWorkload                     = "DW"
                + displayName                    = "DisplayName"
                + isAutoScalingEnabled           = false
                + isAutoScalingForStorageEnabled = false
                + isMtlsConnectionRequired       = true
                + licenseModel                   = "LicenseIncluded"
                + ncharacterSet                  = "AL16UTF16"
                + permissionLevel                = "Restricted"
                }
            }
        + id                        = (known after apply)
        + ignore_casing             = false
        + ignore_missing_property   = true
        + ignore_null_property      = false
        + location                  = "eastus"
        + name                      = "<db_name>"
        + output                    = (known after apply)
        + parent_id                 = "/subscriptions/<subscription_id>/resourceGroups/<resource_group>"
        + response_export_values    = [
            + "id",
            + "properties.ocid",
            + "properties",
            ]
        + schema_validation_enabled = false
        + sensitive_body            = (write-only attribute)
        + type                      = "Oracle.Database/autonomousDatabases@2023-09-01"
        }

    Plan: 1 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

    azapi_resource.autonomous_db: Creating...
    azapi_resource.autonomous_db: Still creating... [00m10s elapsed]
    azapi_resource.autonomous_db: Still creating... [00m20s elapsed]
    azapi_resource.autonomous_db: Still creating... [00m30s elapsed]
    azapi_resource.autonomous_db: Still creating... [00m40s elapsed]
    azapi_resource.autonomous_db: Still creating... [00m50s elapsed]
    azapi_resource.autonomous_db: Still creating... [01m00s elapsed]
    azapi_resource.autonomous_db: Still creating... [01m10s elapsed]
    azapi_resource.autonomous_db: Still creating... [01m20s elapsed]
    azapi_resource.autonomous_db: Still creating... [01m30s elapsed]
    azapi_resource.autonomous_db: Still creating... [01m40s elapsed]
    azapi_resource.autonomous_db: Still creating... [01m50s elapsed]
    azapi_resource.autonomous_db: Still creating... [02m00s elapsed]
    azapi_resource.autonomous_db: Still creating... [02m10s elapsed]
    azapi_resource.autonomous_db: Still creating... [02m20s elapsed]
    azapi_resource.autonomous_db: Still creating... [02m30s elapsed]
    azapi_resource.autonomous_db: Still creating... [02m40s elapsed]
    azapi_resource.autonomous_db: Still creating... [02m50s elapsed]
    azapi_resource.autonomous_db: Still creating... [03m00s elapsed]
    azapi_resource.autonomous_db: Still creating... [03m10s elapsed]
    azapi_resource.autonomous_db: Creation complete after 3m12s [id=/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Oracle.Database/autonomousDatabases/<db_name>]

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```
9. Validate the Autonomous Database has been created. Go to the Oracle Database@Azure service and find your database.

    ![Search or Oracle Database@Azure service](images/searchfororacledbatazure.png)

    ![Find the created Oracle Database@Azure](images/findyouradb.png)

