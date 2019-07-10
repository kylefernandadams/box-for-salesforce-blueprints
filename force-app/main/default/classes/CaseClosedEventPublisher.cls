public with sharing class CaseClosedEventPublisher {
    private static final String BOX_BASE_URL = 'https://api.box.com/2.0/'; 
    private static final String GET_CHILDREN_URL = 'folders/{0}/items';
    private static final String HTTP_METHOD_GET = 'GET';
    private static final String CONTENT_TYPE_HEADER = 'Content-Type';
    private static final String APPLICATION_JSON = 'application/json';


    @future(callout=true)
    public static void publishEvent(Id caseId, Id accountId, String caseNumber) {
        System.debug('Publishing event with target account record id: ' + accountId);

        // Instantiate the Toolkit object
        box.Toolkit boxToolkit = new box.Toolkit();

        // Get case folder id
        String caseFolderId = boxToolkit.getFolderIdByRecordId(caseId);
        System.debug('Found case folder id: ' + caseFolderId);

        // Get existing or create target Box parent account folder id
        String accountFolderId = boxToolkit.createFolderForRecordId(accountId, null, true);
        System.debug('Found account folder id: ' + accountFolderId);

        // NOTE: If you want to add a collab and dynamically create the folder, use the following
        // box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
        // String collabId = boxToolkit.createCollaborationOnRecord(userId, recordId, collabType, true);

        // Create the archive subfolder
        String subFolderName = 'archived-case-content-' + caseNumber;
        String subFolderId = boxToolkit.createFolder(subFolderName, accountFolderId, null);
        System.debug('Created subfolder with id: ' + subFolderId + ' and name: ' + subFolderName);

        // Instantiate a list to hold Case_Closed__e events
        List<Case_Closed__e> caseClosedEvents = new List<Case_Closed__e>();

        // Get child items of the case folder and add to event list
        Integer offset = 0;
        Integer limitCount = 500;

        // Create box get children request manually
        String urlParams = '?offset=' + offset + '&limit=' + limitCount;
    	String url = BOX_BASE_URL + String.format(GET_CHILDREN_URL, new String[] { caseFolderId }) + urlParams;
        HttpRequest request = new HttpRequest();
        request.setMethod(HTTP_METHOD_GET);
        request.setEndpoint(url);
        request.setHeader(CONTENT_TYPE_HEADER, APPLICATION_JSON);
    	
        // Send request and get response body
    	HttpResponse response = boxToolkit.sendRequest(request);
    	String responseBody = response.getBody();   	
    	BoxGenericJsonObject responseObject = new BoxGenericJsonObject(responseBody);
    	
        // Check if there are any children. total_count = null means there are no children
        if (responseObject.getValue('total_count') != null) {
    		Integer totalCount = Integer.valueOf(responseObject.getValue('total_count'));
    		
            // Get the entries JSON object and loop through each item
            list<String> childEntries = BoxJsonObject.parseJsonObjectArray(responseObject.getValue('entries'));
    		for (String entry : childEntries) {
    			BoxGenericJsonObject entryObject = new BoxGenericJsonObject(entry);
                String itemId = entryObject.getValue('id');
    			String itemType = entryObject.getValue('type');
    			
                // Add the item to the Case_Closed_e events list
                caseClosedEvents.add(new Case_Closed__e(
                    Box_Item_ID__c = itemId,
                    Box_Item_Type__c = itemType,
                    Box_Parent_ID__c = subFolderId
                ));
    		}
        }

        // Publish Case_Closed__d events
        List<Database.SaveResult> caseClosedPublishResults = EventBus.publish(caseClosedEvents);
        
        // Loop through results
        for(Database.SaveResult publishResult: caseClosedPublishResults) {
            if (publishResult.isSuccess()) {
                // System.debug('Successfully published Case_Closed__e event for event id: ' + publishResult.getId());
            } else {
                for(Database.Error err : publishResult.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }

        // Commit changes
        boxToolkit.commitChanges();
    }
}
