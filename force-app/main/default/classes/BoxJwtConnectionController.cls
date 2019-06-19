public with sharing class BoxJwtConnectionController {
    
    // Get a list of Box JWT Connections
    @AuraEnabled(cacheable=true)
    public static List<Box_Jwt_Connection__c> getBoxJwtConnectionList(){
        return [SELECT Connection_Name__c, Is_Default__c, Public_Key_ID__c, Client_ID__c, Client_Secret__c, Enterprise_ID__c FROM Box_Jwt_Connection__c];
    }

   
    // Used for testing the connection when adding a new JWT Connection
    @AuraEnabled(cacheable=true)
    public static String testJwtConnection(
        String enterpriseID, 
        String clientID, 
        String clientSecret, 
        String publicKeyID, 
        String privateKey){
        
        // Get a connection and the current user
        System.debug('Starting JWt connection test!');
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(publicKeyID);
        preferences.setPrivateKey(privateKey);
        BoxPlatformApiConnection testApiConnection = BoxPlatformApiConnection.getAppEnterpriseConnection(enterpriseID, clientID, clientSecret, preferences);
        BoxUser.Info currentUser = BoxUser.getCurrentUser(testApiConnection);
        
        System.debug('Found user with login: ' + currentUser.login);
        return JSON.serialize(currentUser);
    }

    // Insert a new Box JWT Connection and Add the service account to the root folder
    @AuraEnabled
    public static void createBoxJwtConnection(
        String jwtConnectionName,
        String enterpriseID, 
        String clientID, 
        String clientSecret, 
        String publicKeyID, 
        String serviceAccountID,
        String serviceAccountLogin,
        String serviceAccountName,
        String privateKey){

        // Instantiate the Toolkit object
        box.Toolkit boxToolkit = new box.Toolkit();

        // Get the root folder for the Box for Salesforce integration
        String rootFolderId = boxToolkit.getRootFolderId();

        // Collaborate the new service account user into the root folder
        box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
        String collabId = boxToolkit.createCollaboration(rootFolderId, serviceAccountID, null, collabType, null);
        System.debug('Added service account to the root salesforce folder with collaboration id: ' + collabId);

        // Commit changes
        boxToolkit.commitChanges();

        // Insert a new Box JWT Connection
        Box_Jwt_Connection__c boxJwtConnection = new Box_Jwt_Connection__c(
            Connection_Name__c = jwtConnectionName,
            Public_Key_ID__c = publicKeyID, 
            Client_ID__c = clientID, 
            Client_Secret__c = clientSecret, 
            Enterprise_ID__c = enterpriseID, 
            Service_Account_ID__c = serviceAccountID,
            Service_Account_Login__c = serviceAccountLogin,
            Service_Account_Name__c = serviceAccountName,
            Private_Key__c = privateKey
        );
        insert boxJwtConnection;
    }
}
