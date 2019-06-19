trigger AccountFolderCreation on Account (after insert) {

    boolean isFirstRun = true;
    for(Account insertedAccount: Trigger.new) {
        if(isFirstRun) {
            BoxRecordFolderHandler.createFolder(insertedAccount.Id, UserInfo.getUserId());
            isFirstRun = false;
        }
    }
}