public class CellOrderController {
    @AuraEnabled(cacheable=true)
    public static CellOrder__c getOrderFields(Id cellOrderId) {
        CellOrder__c order = [SELECT ParcelLocker__c, Order__c FROM CellOrder__c WHERE Id=:cellOrderId];
        return order;
    }
}