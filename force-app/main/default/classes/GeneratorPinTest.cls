@isTest
public class GeneratorPinTest {
    @isTest
    static void testPinGenerate() {
        ParcelLocker__c parcelLocker = new ParcelLocker__c(Name = '12345', Location__Latitude__s = 50.42, Location__Longitude__s = 43.53);
        insert parcelLocker;
        
        Cell__c cell = new Cell__c(Availability__c = 'Empty', Status__c = 'Open', Position__c = 'A-1', ParcelLocker__c = parcelLocker.Id);
        insert cell;
        
        cell.Availability__c = 'Full';
        cell.Status__c = 'Closed';
        update cell;
        
        Cell__c updatedCell = [SELECT Id, Availability__c, Status__c, Pin__c FROM Cell__c WHERE Id = :cell.Id];
        
        System.assertNotEquals(null, updatedCell.Pin__c, 'Pin should not be null');
        System.assertEquals(6, updatedCell.Pin__c.length(), 'Pin should have 6 digits');
        System.assertEquals('Full', updatedCell.Availability__c, 'Availability should be Full');
        System.assertEquals('Closed', updatedCell.Status__c, 'Status should be Closed');
    }
}