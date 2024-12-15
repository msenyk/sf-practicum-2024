@isTest
public class CellOrderTriggerHandlerTest {
    @isTest
    static void testAfterInsert() {
        // Arrange
        ParcelLocker__c locker = new ParcelLocker__c(Name = '123', Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194);
        insert locker;
        
        Cell__c cell = new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-1', Size__c = 'Small');
        insert cell;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
    
        Contract contract = new Contract(AccountId = account.Id, StartDate = Date.today());
        insert contract;
    
        Contact contact = new Contact(FirstName = 'John', LastName = 'Smith', AccountId = account.Id);
        insert contact;

        Order order = new Order(
            AccountId = account.Id,
            ContractId = contract.Id,
            Parcel_Width__c = 16,
            Parcel_Height__c = 9,
            Parcel_Depth__c = 47,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
    	insert order;

        CellOrder__c cellOrder = new CellOrder__c(
            ParcelLocker__c = locker.Id,
            Cell__c = cell.Id,
            Order__c = order.Id,
            Contact__c = contact.Id,
            State__c = 'Delivered'
    	);
        // Disabling the trigger while testing
        CellOrderTriggerHandler.triggerIsDisabled = true;
		insert cellOrder;
		CellOrderTriggerHandler handler = new CellOrderTriggerHandler(true, 1);
        List<CellOrder__c> cellOrders = new List<CellOrder__c>{cellOrder};
        Map<Id, CellOrder__c> cellOrdersMap = new Map<Id, CellOrder__c>(cellOrders);
        
        // Act
        Test.startTest();
        handler.afterInsert(cellOrders, cellOrdersMap);
        Test.stopTest();
            
        // Assert
        System.assertEquals(0, cellOrders[0].getErrors().size(), 'No error should occur for valid dimensions.');
    }
    
    @isTest
    static void testAfterUpdate() {
        // Arrange
        ParcelLocker__c locker = new ParcelLocker__c(Name = '123', Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194);
        insert locker;
        
        Cell__c cell = new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed', Position__c = 'A-1', Size__c = 'Small');
        insert cell;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
    
        Contract contract = new Contract(AccountId = account.Id, StartDate = Date.today());
        insert contract;
    
        Contact contact = new Contact(FirstName = 'John', LastName = 'Smith', AccountId = account.Id);
        insert contact;

        Order existingOrder = new Order(
            AccountId = account.Id,
            ContractId = contract.Id,
            Parcel_Width__c = 5,
            Parcel_Height__c = 8,
            Parcel_Depth__c = 10,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
    	insert existingOrder;

        CellOrder__c existingCellOrder = new CellOrder__c(
            ParcelLocker__c = locker.Id,
            Order__c = existingOrder.Id,
            Contact__c = contact.Id,
            State__c = 'Pending delivery'
    	);
        insert existingCellOrder;
        
        Order newOrder = new Order(
            AccountId = account.Id,
            ContractId = contract.Id,
            Parcel_Width__c = 15,
            Parcel_Height__c = 9,
            Parcel_Depth__c = 47,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        // Disabling the trigger while testing
        CellOrderTriggerHandler.triggerIsDisabled = true;
        insert newOrder;
        CellOrder__c updatedCellOrder = existingCellOrder;
        updatedCellOrder.Order__c = newOrder.Id;
       	update updatedCellOrder;
        
        List<CellOrder__c> oldCellOrders = new List<CellOrder__c>{existingCellOrder};
        List<CellOrder__c> newCellOrders = new List<CellOrder__c>{updatedCellOrder};
        
        Map<Id, CellOrder__c> oldCellOrdersMap = new Map<Id, CellOrder__c>(oldCellOrders);
        Map<Id, CellOrder__c> newCellOrdersMap = new Map<Id, CellOrder__c>(newCellOrders);
        
        CellOrderTriggerHandler handler = new CellOrderTriggerHandler(true, 1);
        
        // Act
        Test.startTest();
        handler.afterUpdate(oldCellOrders, newCellOrders, oldCellOrdersMap, newCellOrdersMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, newCellOrders[0].getErrors().size(), 'No error should occur for valid dimensions.'); 
    }
}