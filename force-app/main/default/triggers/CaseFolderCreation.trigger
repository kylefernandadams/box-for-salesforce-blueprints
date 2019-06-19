trigger CaseFolderCreation on Case (after insert) {

    boolean isFirstRun = true;
    for(Case insertedCase: Trigger.new) {
        if(isFirstRun) {
            BoxRecordFolderHandler.createFolder(insertedCase.Id, UserInfo.getUserId());
            isFirstRun = false;
        }
    }
}