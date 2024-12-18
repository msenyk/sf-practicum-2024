public without sharing class OrderTriggerHandler implements TriggerHandler {
    public static boolean triggerIsDisabled = false;
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public OrderTriggerHelper helper;
    public OrderTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new OrderTriggerHelper();
    }
    public void beforeInsert(List<Order> newOrders) {
         helper.setPricebooksForOrders(newOrders);
    }
    public void beforeUpdate(List<Order> oldOrders, List<Order> newOrders, Map<ID, SObject> oldOrdersMap, Map<ID, SObject> newOrdersMap) {
        // helper.doTask();
    }
    public void beforeDelete(List<Order> oldOrders, Map<ID, SObject> oldOrdersMap) {
        // helper.doTask();
    }
    public void afterInsert(List<Order> newOrders, Map<ID, SObject> newOrdersMap) {
         helper.copyOpportunityProductsToOrder(newOrders);
    }
    public void afterUpdate(List<Order> oldOrders, List<Order> newOrders, Map<ID, SObject> oldOrdersMap, Map<ID, SObject> newOrdersMap) {
        // helper.doTask();
    }
    public void afterDelete(List<Order> oldOrders, Map<ID, SObject> oldOrdersMap) {
        // helper.doTask();
    }
    public void afterUndelete(List<Order> newOrders, Map<ID, SObject> newOrdersMap) {
        // helper.doTask();
    }
}