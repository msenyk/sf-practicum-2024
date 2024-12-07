@isTest
public class ParcelLockerTriggerHelperTest {
    // Checking for duplicate names in inserted records
	@isTest
    static void testCheckUniqueNames_DuplicateNamesInNewRecords() { 
        // Arrange
        List<ParcelLocker__c> newParcelLockers = new List<ParcelLocker__c>{
            new ParcelLocker__c(Name = '1234', Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194),
            new ParcelLocker__c(Name = '1234', Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194),  
            new ParcelLocker__c(Name = '5678', Location__Latitude__s = 24.8849, Location__Longitude__s = -110.3694)
        };
        ParcelLockerTriggerHelper helper = new ParcelLockerTriggerHelper();
		
        // Act
        Test.startTest();
        helper.checkUniqueNames(newParcelLockers);
        Test.stopTest();

      	// Assert
        System.assertEquals(1, newParcelLockers[0].getErrors().size(), 'There should be an error due to duplication.');
        System.assertEquals(1, newParcelLockers[1].getErrors().size(), 'There should be an error due to duplication.');
    }
    
    // Checking for duplicate names in existing records
    @isTest
    static void testCheckUniqueNames_DuplicateNamesInExistingRecords() {
        // Arrange
        ParcelLocker__c existingParcelLocker = new ParcelLocker__c(Name = '1234', Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194);
        insert existingParcelLocker;
        List<ParcelLocker__c> newParcelLockers = new List<ParcelLocker__c>{
            new ParcelLocker__c(Name = '1234', Location__Latitude__s = 48.1349, Location__Longitude__s = -100.5154),
            new ParcelLocker__c(Name = '5678', Location__Latitude__s = 24.8849, Location__Longitude__s = -110.3694)
        };
        ParcelLockerTriggerHelper helper = new ParcelLockerTriggerHelper();

        // Act
        Test.startTest();
        helper.checkUniqueNames(newParcelLockers);
        Test.stopTest();

        // Assert
        System.assertEquals(1, newParcelLockers[0].getErrors().size(), 'There should be an error due to duplication.');
        System.assertEquals(0, newParcelLockers[1].getErrors().size(), 'Errors should not occur.');
    }
}