public with sharing class OrderController {
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(Id orderId) {
        try {
            return [
                SELECT Id, Product2.Name, Quantity, UnitPrice, Product2.Width__c, Product2.Height__c, Product2.Length__c
                FROM OrderItem
                WHERE OrderId = :orderId
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order products: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateParcelDimensions(Id orderId, Decimal width, Decimal height, Decimal depth) {
        if (orderId == null) {
            throw new IllegalArgumentException('Order ID must not be null');
        }
        
        Order orderToUpdate = [SELECT Id, Parcel_Width__c, Parcel_Height__c, Parcel_Depth__c FROM Order WHERE Id = :orderId LIMIT 1];

        if (orderToUpdate != null) {
            orderToUpdate.Parcel_Width__c = width;
            orderToUpdate.Parcel_Height__c = height;
            orderToUpdate.Parcel_Depth__c = depth;
            update orderToUpdate;
        }
    }
}