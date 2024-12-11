public with sharing class CellOrderTriggerHelper {
    public void validateParcelDimensions(List<CellOrder__c> newOrders) {
        // Collecting all Ids for queries
        Set<Id> cellIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        
        for (CellOrder__c cellOrder : newOrders) {
            cellIds.add(cellOrder.Cell__c);
            orderIds.add(cellOrder.Order__c);
        }
        
        Map<Id, Cell__c> cellsMap = new Map<Id, Cell__c>(
            [SELECT Width__c, Height__c, Depth__c FROM Cell__c WHERE Id IN :cellIds]
        );
        
        Map<Id, Order> ordersMap = new Map<Id, Order>(
            [SELECT Parcel_Width__c, Parcel_Height__c, Parcel_Depth__c FROM Order WHERE Id IN :orderIds]
        );
        
        for (CellOrder__c cellOrder : newOrders) {
            Cell__c cell = cellsMap.get(cellOrder.Cell__c);
            Order order = ordersMap.get(cellOrder.Order__c);
            
            //If Cell or Order is empty
            if (cell == null || order == null) {
                continue;
            }
            
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