public with sharing class BoxRecordFolderHandler {
    @future(callout=true)
    public static void createFolder(Id recordId, Id userId) {
        // Instantiate the Toolkit object
        box.Toolkit boxToolkit = new box.Toolkit();

        // Create folder with editor permissions
        box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
        String collabId = boxToolkit.createCollaborationOnRecord(userId, recordId, collabType, true);
        System.debug('Created new folder with collaboration id: ' + collabId);

        // Commit changes
        boxToolkit.commitChanges();
    }
}
