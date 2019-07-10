trigger CaseClosedEventTrigger on Case_Closed__e (after insert) {
    public static final Integer MAX_BATCH_SIZE = 50;

    Integer batchCount = 0;
    for(Case_Closed__e caseClosedEvent: Trigger.new) {
        // If the batch count is above the Apex object trigger max of 200, then exit the loop
        batchCount++;
        if(batchCount > MAX_BATCH_SIZE) {
            break;
        }
        else {
            try{
                // Process the event
                CaseClosedEventSubscriber.processEvent(caseClosedEvent.Box_Item_ID__c, caseClosedEvent.Box_Item_Type__c, caseClosedEvent.Box_Parent_ID__c);
            }
            catch(Exception e) {
                System.debug('Failed to process event: ' + e.getMessage());
                throw new EventBus.RetryableException('Failed processing event. Retrying the trigger...');
            }
        }
        // Set the resume checkpoint just in case 
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(caseClosedEvent.replayId);
    
    }
}