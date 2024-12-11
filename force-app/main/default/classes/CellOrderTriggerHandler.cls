public without sharing class CellOrderTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public CellOrderTriggerHelper helper;
    public CellOrderTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new CellOrderTriggerHelper();
    }
    public void beforeInsert(List<CellOrder__c> newOrders) {
         helper.validateParcelDimensions(newOrders);
    }
    public void beforeUpdate(List<CellOrder__c> oldOrders, List<CellOrder__c> newOrders, Map<ID, SObject> oldOrdersMap, Map<ID, SObject> newOrdersMap) {
         helper.validateParcelDimensions(newOrders);
    }
    public void beforeDelete(List<CellOrder__c> oldOrders, Map<ID, SObject> oldOrdersMap) {
        // helper.doTask();
    }
    public void afterInsert(List<CellOrder__c> newOrders, Map<ID, SObject> newOrdersMap) {
        // helper.doTask();
    }
    public void afterUpdate(List<CellOrder__c> oldOrders, List<CellOrder__c> newOrders, Map<ID, SObject> oldOrdersMap, Map<ID, SObject> newOrdersMap) {
        // helper.doTask();
    }
    public void afterDelete(List<CellOrder__c> oldOrders, Map<ID, SObject> oldOrdersMap) {
        // helper.doTask();
    }
    public void afterUndelete(List<CellOrder__c> newOrders, Map<ID, SObject> newOrdersMap) {
        // helper.doTask();
    }
}