public with sharing class BoxContentExplorerController {

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getContentExplorerMap(String recordId) {
        System.debug('Found record id: ' + recordId);

        // Get a service account connection
        BoxConnection box = BoxConnection.getInstance();
        BoxPlatformApiConnection api = box.api;

        // Get the record folder
        box__FRUP__c frup = [SELECT box__Folder_ID__c, box__Record_ID__c FROM box__FRUP__c WHERE box__Record_ID__c = :recordId LIMIT 1];
        String folderId = frup.box__Folder_ID__c;
        System.debug('Found folder with id: ' + folderId);
  
        // Get the service account access token
        String accessToken = box.accessToken;
  
        // Create a resource for the folder
        String resource = 'https://api.box.com/2.0/folders/' + folderId;
        System.debug('Downscoping resource: ' + resource);

        // Exchange the service account access token for a downscoped token that is safer
        String scopes = 'base_explorer item_preview item_download item_rename item_delete item_share item_upload';
        String downscopedToken = BoxConnection.exchangeToken(accessToken, scopes, resource); 

        // Create the map to return to the lightning component
        Map<String,String> contentExplorerMap = new Map<String,String>();
        contentExplorerMap.put('downscopedToken', downscopedToken);
        contentExplorerMap.put('folderId', folderId);
        return contentExplorerMap;
    }
}
