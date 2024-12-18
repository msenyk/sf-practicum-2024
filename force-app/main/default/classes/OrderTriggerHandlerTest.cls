@isTest
public class OrderTriggerHandlerTest {
    @isTest
    static void testBeforeInsert() {
        // Arrange
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Id standardPricebook = Test.getStandardPricebookId();
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = account.Id,
            Pricebook2Id = standardPricebook
        );
        insert opportunity;
        
        Order order = new Order(
            AccountId = account.Id,
            OpportunityId = opportunity.Id,
            Pricebook2Id = standardPricebook, 
            Status = 'Draft',
            EffectiveDate = Date.today()
        );

        List<Order> orders = new List<Order>{order};
        OrderTriggerHandler handler = new OrderTriggerHandler(true, 1);
        
        // Act
        Test.startTest();
        handler.beforeInsert(orders);
        Test.stopTest();
        
        // Assert
        System.assertEquals(standardPricebook, orders[0].Pricebook2Id, 'Order should have the pricebook from the related Opportunity.');
    }
    
    @isTest
    static void testAfterInsert() {
        // Arrange
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
        Map<Id, Order> ordersMap = new Map<Id, Order>(orders);
		OrderTriggerHandler handler = new OrderTriggerHandler(true, 1);        
        
        // Act
        Test.startTest();
        handler.afterInsert(orders, ordersMap);
        Test.stopTest();

        // Assert
        List<OrderItem> orderProducts = [SELECT Id, OrderId, Quantity, PricebookEntryId, UnitPrice FROM OrderItem WHERE OrderId = :order.Id];      
        System.assertEquals(5, orderProducts.size(), 'There should be five OrderItems created.');
    }
}