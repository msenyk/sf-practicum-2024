public without sharing class ParcelLockerTriggerHandler implements TriggerHandler{
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public ParcelLockerTriggerHelper helper;
    public ParcelLockerTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new ParcelLockerTriggerHelper();
    }
    public void beforeInsert(List<ParcelLocker__c> newParcelLockers) {
         helper.checkUniqueNames(newParcelLockers);
    }
    public void beforeUpdate(List<ParcelLocker__c> oldParcelLockers, List<ParcelLocker__c> newParcelLockers, Map<ID, SObject> oldParcelLockersMap, Map<ID, SObject> newParcelLockersMap) {
         helper.checkUniqueNames(newParcelLockers);
    }
    public void beforeDelete(List<ParcelLocker__c> oldParcelLockers, Map<ID, SObject> oldParcelLockersMap) {
        // helper.doTask();
    }
    public void afterInsert(List<ParcelLocker__c> newParcelLockers, Map<ID, SObject> newParcelLockersMap) {
        // helper.doTask();
    }
    public void afterUpdate(List<ParcelLocker__c> oldParcelLockers, List<ParcelLocker__c> newParcelLockers, Map<ID, SObject> oldParcelLockersMap, Map<ID, SObject> newParcelLockersMap) {
        // helper.doTask();
    }
    public void afterDelete(List<ParcelLocker__c> oldParcelLockers, Map<ID, SObject> oldParcelLockersMap) {
        // helper.doTask();
    }
    public void afterUndelete(List<ParcelLocker__c> newParcelLockers, Map<ID, SObject> newParcelLockersMap) {
        // helper.doTask();
    }
}