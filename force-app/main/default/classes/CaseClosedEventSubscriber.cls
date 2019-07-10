public with sharing class CaseClosedEventSubscriber {

    @future(callout=true)
    public static void processEvent(String itemId, String itemType, String parentId) {
        // Get Box JWT Connection
        BoxConnection box = BoxConnection.getInstance();
        BoxPlatformApiConnection api = box.api;

        // Check if the item type is a folder or file, then move the item
        if(itemType == 'folder') {
            // Get an instance of the child folder and target folder
            BoxFolder boxFolder = new BoxFolder(api, itemId);
            BoxFolder targetFolder = new BoxFolder(api, parentId);

            // Move to target folder
            boxFolder.move(targetFolder);
        }
        else if(itemType == 'file') {
            BoxFile boxFile = new BoxFile(api, itemId);
            
            // Create the info object for the id
            BoxFile.Info idInfo = new BoxFile.Info();
            idInfo.addValue('id', parentId);

            // Create the info object for the parent folder info
            BoxFile.Info parentInfo = new BoxFile.Info();
            parentInfo.addValue('parent', idInfo.getJsonString());

            // Update the file info to set the new parent id
            boxFile.updateFileInfo(parentInfo);
        }
        System.debug('Moved item with id: ' + itemId + ' to parent id: ' + parentId);
    }
}
