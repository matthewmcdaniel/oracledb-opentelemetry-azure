
resource autonomousDatabases_adbsatazure_name_resource 'Oracle.Database/autonomousDatabases@2025-03-01' = {
  location: 'eastus'
  name: 'testbicepdeployment'
  properties: {
    adminPassword: 'Test_Password_123'
    backupRetentionPeriodInDays: 60
    characterSet: 'AL32UTF8'
    computeCount: 2
    computeModel: 'ECPU'
    customerContacts: [
      {
        email: 'matthew.mcdaniel@oracle.com'
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
