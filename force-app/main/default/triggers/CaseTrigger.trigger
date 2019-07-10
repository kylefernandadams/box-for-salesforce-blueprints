trigger CaseTrigger on Case (after insert, after update) {
    boolean isFirstRun = true;
    for(Case triggeredCase: Trigger.new) {
        if(isFirstRun) {
            if(Trigger.isInsert) {
                // Call Apex to create Box folder
                BoxRecordFolderHandler.createFolder(triggeredCase.Id, UserInfo.getUserId());
            }
            else if(Trigger.isUpdate) {
                if(triggeredCase.IsClosed && triggeredCase.Status == 'Closed') {
                    System.debug('Found closed case from trigger with id: ' + triggeredCase.Id);
                    
                    // Call Apex publish a platform event to move files to a new parent folder
                    CaseClosedEventPublisher.publishEvent(triggeredCase.Id, triggeredCase.AccountId, triggeredCase.CaseNumber);
                }
            }
            isFirstRun = false;
        }
    }
}