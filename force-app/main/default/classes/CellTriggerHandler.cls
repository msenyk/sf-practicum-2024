public without sharing class CellTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public CellTriggerHelper helper;
    public CellTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new CellTriggerHelper();
    }
    public void beforeInsert(List<Cell__c> newCells) {
        // helper.doTask1();
        // helper.doTask2();
    }
    public void beforeUpdate(List<Cell__c> oldCells, List<Cell__c> newCells, Map<ID, SObject> oldCellsMap, Map<ID, SObject> newCellsMap) {
        // helper.doTask3();
        // helper.doTask4();
    }
    public void beforeDelete(List<Cell__c> oldCells, Map<ID, SObject> oldCellsMap) {
        // helper.doTask5();
        // helper.doTask1();
    }
    public void afterInsert(List<Cell__c> newCells, Map<ID, SObject> newCellsMap) {
        // helper.doTask2();
        // helper.doTask3();
    }
    public void afterUpdate(List<Cell__c> oldCells, List<Cell__c> newCells, Map<ID, SObject> oldCellsMap, Map<ID, SObject> newCellsMap) {
        // helper.doTask4();
        // helper.doTask5();
    }
    public void afterDelete(List<Cell__c> oldCells, Map<ID, SObject> oldCellsMap) {
        // helper.doTask3();
        // helper.doTask1();
    }
    public void afterUndelete(List<Cell__c> newCells, Map<ID, SObject> newCellsMap) {
        // helper.doTask4();
        // helper.doTask2();
    }
}