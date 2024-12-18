public with sharing class CellOrderTriggerHelper {
    public void validateParcelDimensions(List<CellOrder__c> newOrders, Map<ID, SObject> newOrdersMap) {
        // Collecting all orders
        List<CellOrder__c> queriedOrders = [
            SELECT Id,
                   Cell__r.Width__c, Cell__r.Height__c, Cell__r.Depth__c,
                   Order__r.Parcel_Width__c, Order__r.Parcel_Height__c, Order__r.Parcel_Depth__c
            FROM CellOrder__c
            WHERE Id IN :newOrders
        ]; 
        for (CellOrder__c cellOrder : queriedOrders) {
            
            // If Cell or Order is empty
            if (cellOrder.Cell__r.Id == null) {
                continue;
            }
            
            Cell__c cell = cellOrder.Cell__r;
            Order order = cellOrder.Order__r;

            // Parcel dimensions
            Decimal parcelWidth = order.Parcel_Width__c;
            Decimal parcelHeight = order.Parcel_Height__c;
            Decimal parcelDepth = order.Parcel_Depth__c;

            // Cell dimensions
            Decimal cellWidth = cell.Width__c;
            Decimal cellHeight = cell.Height__c;
            Decimal cellDepth = cell.Depth__c;
            
            // Check orientation
            Boolean fits = (
                (parcelDepth <= cellDepth && parcelWidth <= cellWidth && parcelHeight <= cellHeight) ||
                (parcelDepth <= cellDepth && parcelHeight <= cellWidth && parcelWidth <= cellHeight) ||
                (parcelWidth <= cellDepth && parcelDepth <= cellWidth && parcelHeight <= cellHeight) ||
                (parcelWidth <= cellDepth && parcelHeight <= cellWidth && parcelDepth <= cellHeight) ||
                (parcelHeight <= cellDepth && parcelWidth <= cellWidth && parcelDepth <= cellHeight) ||
                (parcelHeight <= cellDepth && parcelDepth <= cellWidth && parcelWidth <= cellHeight)
            );

            // If the parcel dimensions doesn't fit
            if (!fits) {
                CellOrder__c newOrder = (CellOrder__c) newOrdersMap.get(cellOrder.Id);
                newOrder.Cell__c.addError('This cell is not large enough to store this package.');
            }
        }
    }  
}