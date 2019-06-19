public with sharing class BoxAppUserHandler {
    private static final String USERS_URL_TEMPLATE = 'users';

    @future(callout=true)
    public static void createAppUser(String name, String userRecordID) {
        // Get an instance of a BoxPlatformApiConnection
        BoxConnection box = BoxConnection.getInstance();
        BoxPlatformApiConnection api = box.api;

        // Construct the request body to send to Box
        BoxGenericJsonObject requestJson = new BoxGenericJsonObject();
        requestJson.addValue('name', 'SFDC ' + name);
        requestJson.addValue('is_platform_access_only', 'true');
        requestJson.addValue('external_app_user_id', userRecordID);

        // Construct the request object
        String createAppUserUrl = api.baseUrl + USERS_URL_TEMPLATE;
        BoxApiRequest request = new BoxApiRequest(api, createAppUserUrl, BoxApiRequest.METHOD_POST);
        request.setBody(requestJson.getJsonString());
        request.setTimeout(api.timeout);
        request.addJsonContentTypeHeader();

        // Sent the POST request to Box to create the App User
        HttpResponse response = request.send();
        String responseBody = BoxApiRequest.getBoxResourceResponseBody(response, 'BoxUser.createEnterpriseUser');
        BoxUser.Info boxAppUserInfo = new BoxUser.Info(responseBody);
        System.debug('Created App User with name: ' + boxAppUserInfo.name + ' and id: ' + boxAppUserInfo.id);
    }
    
}
