public without sharing class CellOrderTriggerHelper {
    public CellOrderTriggerHelper() {}
    public void validateParcelDimensions(List<CellOrder__c> newOrders) {
        for (CellOrder__c cellOrder : newOrders) {
        // Retrieving related objects
        Cell__c cell = [SELECT Width__c, Height__c, Depth__c FROM Cell__c WHERE Id = :cellOrder.Cell__c];
        Order order = [SELECT Parcel_Width__c, Parcel_Height__c, Parcel_Depth__c FROM Order WHERE Id = :cellOrder.Order__c];
        
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
            cellOrder.Cell__c.addError('This cell is not large enough to store this package.');
        }
    }
    }
}