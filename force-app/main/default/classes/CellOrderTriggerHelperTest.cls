@isTest
public class CellOrderTriggerHelperTest {
    @isTest
    static void testValidateParcelDimensions_ValidDimensions() {
        // Arrange
        ParcelLocker__c locker = new ParcelLocker__c(Name = '123', Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194);
        insert locker;
        
        List<Cell__c> cells = new List<Cell__c>{
            new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-1', Size__c = 'Small'),
            new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-4 (A-1)', Size__c = 'Medium'),
            new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-2', Size__c = 'Big')
        };
        insert cells;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contract contract = new Contract(AccountId = account.Id, StartDate = Date.today());
        insert contract;
        
        Contact contact = new Contact(FirstName = 'John', LastName = 'Smith', AccountId = account.Id);
        insert contact;
        
        List<Order> orders = new List<Order>{
            new Order(
                AccountId = account.Id,
                ContractId = contract.Id,
                Parcel_Width__c = 15,
                Parcel_Height__c = 9,
                Parcel_Depth__c = 47,
                EffectiveDate = Date.today(),
                Status = 'Draft'
            ),
            new Order(
                AccountId = account.Id,
                ContractId = contract.Id,
                Parcel_Width__c = 47,
                Parcel_Height__c = 9,
                Parcel_Depth__c = 32,
                EffectiveDate = Date.today(),
                Status = 'Draft'
            ),
            new Order(
                AccountId = account.Id,
                ContractId = contract.Id,
                Parcel_Width__c = 13,
                Parcel_Height__c = 46,
                Parcel_Depth__c = 47,
                EffectiveDate = Date.today(),
                Status = 'Draft'
            )
        };
        insert orders;
        
        List<CellOrder__c> cellOrders = new List<CellOrder__c>{
            new CellOrder__c(
                ParcelLocker__c = locker.Id,
                Cell__c = cells[0].Id,
                Order__c = orders[0].Id,
                Contact__c = contact.Id,
                State__c = 'Delivered'
            ),
            new CellOrder__c(
                ParcelLocker__c = locker.Id,
                Cell__c = cells[1].Id,
                Order__c = orders[1].Id,
                Contact__c = contact.Id,
                State__c = 'Delivered'
            ),
            new CellOrder__c(
                ParcelLocker__c = locker.Id,
                Cell__c = cells[2].Id,
                Order__c = orders[2].Id,
                Contact__c = contact.Id,
                State__c = 'Delivered'
            )
        };
        // Disabling the trigger while testing
        CellOrderTriggerHandler.triggerIsDisabled = true;
        insert cellOrders;
        Map<Id, CellOrder__c> cellOrdersMap = new Map<Id, CellOrder__c>(cellOrders);
        CellOrderTriggerHelper helper = new CellOrderTriggerHelper();
        
        // Act
        Test.startTest();
        helper.validateParcelDimensions(cellOrders, cellOrdersMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, cellOrders[0].getErrors().size(), 'No error should occur for valid dimensions.');
        System.assertEquals(0, cellOrders[1].getErrors().size(), 'No error should occur for valid dimensions.');
        System.assertEquals(0, cellOrders[2].getErrors().size(), 'No error should occur for valid dimensions.');
    }
    
    @isTest
    static void testValidateParcelDimensions_InvalidDimensions() {
        // Arrange
        ParcelLocker__c locker = new ParcelLocker__c(Name = '123', Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194);
        insert locker;
        
        List<Cell__c> cells = new List<Cell__c>{
            new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-1', Size__c = 'Small'),
            new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-4 (A-1)', Size__c = 'Medium'),
            new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-2', Size__c = 'Big')
        };
        insert cells;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contract contract = new Contract(AccountId = account.Id, StartDate = Date.today());
        insert contract;
        
        Contact contact = new Contact(FirstName = 'John', LastName = 'Smith', AccountId = account.Id);
        insert contact;
        
        List<Order> orders = new List<Order>{
            new Order(
                AccountId = account.Id,
                ContractId = contract.Id,
                Parcel_Width__c = 18,
                Parcel_Height__c = 9,
                Parcel_Depth__c = 47,
                EffectiveDate = Date.today(),
                Status = 'Draft'
            ),
            new Order(
                AccountId = account.Id,
                ContractId = contract.Id,
                Parcel_Width__c = 47,
                Parcel_Height__c = 12,
                Parcel_Depth__c = 32,
                EffectiveDate = Date.today(),
                Status = 'Draft'
            ),
            new Order(
                AccountId = account.Id,
                ContractId = contract.Id,
                Parcel_Width__c = 13,
                Parcel_Height__c = 46,
                Parcel_Depth__c = 50,
                EffectiveDate = Date.today(),
                Status = 'Draft'
            )
        };
        insert orders;
        
        List<CellOrder__c> cellOrders = new List<CellOrder__c>{
            new CellOrder__c(
                ParcelLocker__c = locker.Id,
                Cell__c = cells[0].Id,
                Order__c = orders[0].Id,
                Contact__c = contact.Id,
                State__c = 'Delivered'
            ),
            new CellOrder__c(
                ParcelLocker__c = locker.Id,
                Cell__c = cells[1].Id,
                Order__c = orders[1].Id,
                Contact__c = contact.Id,
                State__c = 'Delivered'
            ),
            new CellOrder__c(
                ParcelLocker__c = locker.Id,
                Cell__c = cells[2].Id,
                Order__c = orders[2].Id,
                Contact__c = contact.Id,
                State__c = 'Delivered'
            )
        };
        // Disabling the trigger while testing
        CellOrderTriggerHandler.triggerIsDisabled = true;
        insert cellOrders;
        Map<Id, CellOrder__c> cellOrdersMap = new Map<Id, CellOrder__c>(cellOrders);
        CellOrderTriggerHelper helper = new CellOrderTriggerHelper();
        
        // Act
        Test.startTest();
        helper.validateParcelDimensions(cellOrders, cellOrdersMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, cellOrders[0].getErrors().size(), 'Expected an error due to invalid dimensions.');
		System.assertEquals(1, cellOrders[1].getErrors().size(), 'Expected an error due to invalid dimensions.');
		System.assertEquals(1, cellOrders[2].getErrors().size(), 'Expected an error due to invalid dimensions.');
    }
}