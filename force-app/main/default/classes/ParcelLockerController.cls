public with sharing class ParcelLockerController {
    public class CellOption {
        @AuraEnabled
        public String label { get; set; }
        
        @AuraEnabled
        public String value { get; set; }

        public CellOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Cell__c> getCells(Id lockerId) {
      
        return [
            SELECT Id, Name, Position__c, Availability__c, ParcelLocker__c, Size__c, Status__c
            FROM Cell__c
            WHERE ParcelLocker__c = :lockerId
            ORDER BY Position__c
        ];
    }
    
    @AuraEnabled
    public static List<CellOption> getAvailableCells(Id parcelLockerId) {
        if (parcelLockerId == null) {
            throw new AuraHandledException('Parcel Locker ID cannot be null');
        }
   
        List<Cell__c> availableCells = [
            SELECT Id, Name, Position__c
            FROM Cell__c
            WHERE ParcelLocker__c = :parcelLockerId
            AND Availability__c = 'Empty'
            ORDER BY Name
        ];
   
        List<CellOption> options = new List<CellOption>();
        for (Cell__c cell : availableCells) {
            options.add(new CellOption(cell.Position__c, cell.Id));
        }
        return options;
    }
}