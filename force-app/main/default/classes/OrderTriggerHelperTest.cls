@isTest
public class OrderTriggerHelperTest {
    @isTest
    static void testSetPricebooksForOrders() {
        // Arrange
        Account account = new Account(Name = 'Test Account');
        insert account;

        Id standardPricebook = Test.getStandardPricebookId();

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Opportunity 1',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = account.Id,
                Pricebook2Id = standardPricebook
        	),
            new Opportunity(
                Name = 'Opportunity 2',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = account.Id
            )
        };
        insert opportunities;
		
        List<Order> orders = new List<Order>{
            new Order(
                AccountId = account.Id,
                OpportunityId = opportunities[0].Id,
                Status = 'Draft',
                EffectiveDate = Date.today()
            ),
            new Order(
                AccountId = account.Id,
                OpportunityId = opportunities[1].Id,
                Status = 'Draft',
                EffectiveDate = Date.today()
            ),
            new Order(
                AccountId = account.Id,
                OpportunityId = opportunities[0].Id,
                Pricebook2Id = standardPricebook, 
                Status = 'Draft',
                EffectiveDate = Date.today()
            )
        };
		OrderTriggerHelper helper = new OrderTriggerHelper();
        
        // Act
        Test.startTest();
        helper.setPricebooksForOrders(orders);
        Test.stopTest();

        // Assert
        System.assertEquals(standardPricebook, orders[0].Pricebook2Id, 'Order should have the pricebook from the related Opportunity.');
        System.assertEquals(null, orders[1].Pricebook2Id, 'Order should not have a pricebook set.');
        System.assertEquals(standardPricebook, orders[2].Pricebook2Id, 'Order should have the standard pricebook.');
    }
    
    @isTest
    static void testCopyOpportunityProductsToOrder() {     
        Account account = new Account(Name = 'Test Account');
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting', 
            CloseDate = Date.today(), 
            AccountId = account.Id
        );
        insert opportunity;

        Product2 product = new Product2(Name = 'Test Product', IsActive = true, Width__c = 10, Height__c = 10, Length__c = 10);
        insert product;
		
        Id standardPricebook = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPricebook,
            UnitPrice = 50.00, 
            IsActive = true
        );
        insert pbe;

        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for (Integer i = 0; i < 5; i++) {
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opportunity.Id,
                Quantity = 1 + i, 
                PricebookEntryId = pbe.Id,
                UnitPrice = 100.00 + i * 50 
            );
            opportunityLineItems.add(oli);
        }
        insert opportunityLineItems;

        Order order = new Order(
            AccountId = account.Id,
            OpportunityId = opportunity.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebook
        );
        // Disabling the trigger while testing
        OrderTriggerHandler.triggerIsDisabled = true;
        insert order;
        List<Order> orders = new List<Order>{order};
		OrderTriggerHelper helper = new OrderTriggerHelper();
        
        // Act
        Test.startTest();
        helper.copyOpportunityProductsToOrder(orders);
        Test.stopTest();

        // Assert
        List<OrderItem> orderProducts = [SELECT Id, OrderId, Quantity, PricebookEntryId, UnitPrice FROM OrderItem WHERE OrderId = :order.Id];      
        System.assertEquals(5, orderProducts.size(), 'There should be five OrderItems created.');
    }
}