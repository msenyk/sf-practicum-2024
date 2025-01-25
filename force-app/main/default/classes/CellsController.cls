public with sharing class CellsController {
    private static final List<String> orderSize = new List<String>{
        'Small',
        'Medium',
        'Big',
        'Large',
        'Extra Large',
        'Jumbo',
        'Mega'
    };
    @AuraEnabled
    public static Id findOptimalCell(Id cellOrderId) {
        if (cellOrderId == null) {
            throw new AuraHandledException('Cell Order ID cannot be null');
        }

        CellOrder__c cellOrder = [
            SELECT Id, Order__c, ParcelLocker__c
            FROM CellOrder__c
            WHERE Id = :cellOrderId
            LIMIT 1
        ];

        if (cellOrder.ParcelLocker__c == null) {
            throw new AuraHandledException('Parcel Locker is not set for this Cell Order');
        }

        if (cellOrder.Order__c == null) {
            throw new AuraHandledException('Order is not set for this Cell Order');
        }

        Order order = [
            SELECT Id, Parcel_Width__c, Parcel_Height__c, Parcel_Depth__c
            FROM Order
            WHERE Id = :cellOrder.Order__c
            LIMIT 1
        ];
      
        List<Cell__c> matchingCells = [
            SELECT Id, Name, Size__c, Width__c, Height__c, Depth__c
            FROM Cell__c
            WHERE ParcelLocker__c = :cellOrder.ParcelLocker__c
              AND Availability__c = 'Empty'
              AND (
                  
                    (Width__c >= :order.Parcel_Width__c AND Height__c >= :order.Parcel_Height__c AND Depth__c >= :order.Parcel_Depth__c) OR

                  
                    (Width__c >= :order.Parcel_Width__c AND Height__c >= :order.Parcel_Depth__c AND Depth__c >= :order.Parcel_Height__c) OR

                  
                    (Width__c >= :order.Parcel_Height__c AND Height__c >= :order.Parcel_Width__c AND Depth__c >= :order.Parcel_Depth__c) OR

                   
                    (Width__c >= :order.Parcel_Height__c AND Height__c >= :order.Parcel_Depth__c AND Depth__c >= :order.Parcel_Width__c) OR
                   
                    (Width__c >= :order.Parcel_Depth__c AND Height__c >= :order.Parcel_Width__c AND Depth__c >= :order.Parcel_Height__c) OR

                    (Width__c >= :order.Parcel_Depth__c AND Height__c >= :order.Parcel_Height__c AND Depth__c >= :order.Parcel_Width__c)
                  )
        ];
       
        if (matchingCells.isEmpty()) {
           
            return null;
        }
 
        matchingCells.sort(new CellSizeComparator());
        return matchingCells[0].Id;
    }
  
    public class CellSizeComparator implements Comparator<Cell__c> {
        public Integer compare(Cell__c a, Cell__c b) {
            Integer indexA = orderSize.indexOf(a.Size__c);
            Integer indexB = orderSize.indexOf(b.Size__c);
            if (indexA == -1) indexA = orderSize.size();
            if (indexB == -1) indexB = orderSize.size();
            if (indexA < indexB) return -1;
            if (indexA > indexB) return 1;
            return 0;
        }
    }
}