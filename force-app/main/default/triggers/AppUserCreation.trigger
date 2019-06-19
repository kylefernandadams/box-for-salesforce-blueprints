trigger AppUserCreation on User (after insert) {

     boolean isFirstRun = true;
    for(User insertedUser: Trigger.new) {
        if(isFirstRun) {
            String userRecordId = insertedUser.Id;
            String name = 'App User ' + insertedUser.FirstName + ' ' + insertedUser.LastName;
            Boolean isPortalEnabled = insertedUser.IsPortalEnabled;
            
            System.debug('Found new user with id: ' + userRecordId + ' name: ' + name + ' and isPortalEnabled: ' + isPortalEnabled);
            if(isPortalEnabled) {
                BoxAppUserHandler.createAppUser(name, userRecordID);
            }
            isFirstRun = false;
        }
    }
}