@isTest
public class ParcelLockerTriggerHandlerTest {
    @isTest
    static void testBeforeInsert() {
        // Arrange
        List<ParcelLocker__c> existingParcelLockers = new List<ParcelLocker__c>{
                new ParcelLocker__c(Name = '1234', Location__Latitude__s = 48.1349, Location__Longitude__s = -100.5154)
        };
        insert existingParcelLockers;
        List<ParcelLocker__c> newParcelLockers = new List<ParcelLocker__c>{
            new ParcelLocker__c(Name = '1234', Location__Latitude__s = 48.1349, Location__Longitude__s = -100.5154),
            new ParcelLocker__c(Name = '5678', Location__Latitude__s = 24.8849, Location__Longitude__s = -110.3694)
        };
        ParcelLockerTriggerHandler handler = new ParcelLockerTriggerHandler(true, newParcelLockers.size());

        // Act
        Test.startTest();
        handler.beforeInsert(newParcelLockers);
        Test.stopTest();

        // Assert
        System.assertEquals(1, newParcelLockers[0].getErrors().size(), 'There should be an error due to duplication.');
        System.assertEquals(0, newParcelLockers[1].getErrors().size(), 'Errors should not occur.');
    }

    @isTest
    static void testBeforeUpdate() {
        // Arrange
        List<ParcelLocker__c> existingParcelLockers = new List<ParcelLocker__c>{
            new ParcelLocker__c(Name = '1234', Location__Latitude__s = 48.1349, Location__Longitude__s = -100.5154),
            new ParcelLocker__c(Name = '5678', Location__Latitude__s = 24.8849, Location__Longitude__s = -110.3694)
        };
        insert existingParcelLockers;
        List<ParcelLocker__c> updatedParcelLockers = existingParcelLockers;
        updatedParcelLockers[0].Name = '5678';

        List<ParcelLocker__c> oldParcelLockers = existingParcelLockers;
        List<ParcelLocker__c> newParcelLockers = updatedParcelLockers;

        Map<Id, ParcelLocker__c> oldParcelLockersMap = new Map<Id, ParcelLocker__c>(oldParcelLockers);
        Map<Id, ParcelLocker__c> newParcelLockersMap = new Map<Id, ParcelLocker__c>(newParcelLockers);

        ParcelLockerTriggerHandler handler = new ParcelLockerTriggerHandler(true, newParcelLockers.size());
		
        // Act
        Test.startTest();
        handler.beforeUpdate(oldParcelLockers, newParcelLockers, oldParcelLockersMap, newParcelLockersMap);
        Test.stopTest();

        // Assert
        System.assertEquals(1, newParcelLockers[0].getErrors().size(), 'There should be an error due to duplication.');
        System.assertEquals(1, newParcelLockers[1].getErrors().size(), 'There should be an error due to duplication.');
    }
}