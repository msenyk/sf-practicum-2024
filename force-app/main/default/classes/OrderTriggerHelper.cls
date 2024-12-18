public class OrderTriggerHelper {
    public void setPricebooksForOrders(List<Order> orders) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Id> oppToPricebookMap = new Map<Id, Id>();
       
        // Collect Opportunity IDs from the provided Orders
        for (Order ord : orders) {
            if (ord.OpportunityId != null) {
                opportunityIds.add(ord.OpportunityId);
            }
        }
        
        // Query Opportunities to get Pricebook2Id using the collected Opportunity IDs
        List<Opportunity> opportunities = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id IN :opportunityIds];
        for (Opportunity opp : opportunities) {
            oppToPricebookMap.put(opp.Id, opp.Pricebook2Id);
        }
		
        // Set each Order Pricebook2Id if it's not already set
        for (Order ord : orders) {
            if (ord.Pricebook2Id == null && oppToPricebookMap.containsKey(ord.OpportunityId)) {
                ord.Pricebook2Id = oppToPricebookMap.get(ord.OpportunityId);
            }
        }
    }
    
    public void copyOpportunityProductsToOrder(List<Order> orders) {
        Set<Id> opportunityIds = new Set<Id>();
        List<OrderItem> orderProductsToInsert = new List<OrderItem>();
        
        // Collect Opportunity IDs
        for (Order ord : orders) {
            if (ord.OpportunityId != null) {
                opportunityIds.add(ord.OpportunityId);
            }
        }
		
        // Get Opportunity Products
        Map<Id, List<OpportunityLineItem>> oppProductsMap = new Map<Id, List<OpportunityLineItem>>();
        List<OpportunityLineItem> oppProducts = [SELECT Id, Quantity, PricebookEntryId, UnitPrice, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds];
        for (OpportunityLineItem oppProduct : oppProducts) {
            if (!oppProductsMap.containsKey(oppProduct.OpportunityId)) {
                oppProductsMap.put(oppProduct.OpportunityId, new List<OpportunityLineItem>());
            }
            oppProductsMap.get(oppProduct.OpportunityId).add(oppProduct);
        }

        // Copy products from Opportunity to Order
        for (Order ord : orders) {
            if (oppProductsMap.containsKey(ord.OpportunityId)) {
                for (OpportunityLineItem oppProduct : oppProductsMap.get(ord.OpportunityId)) {
                    OrderItem orderProduct = new OrderItem();
                    orderProduct.OrderId = ord.Id;
                    orderProduct.Quantity = oppProduct.Quantity;
                    orderProduct.PricebookEntryId = oppProduct.PricebookEntryId;
                    orderProduct.UnitPrice = oppProduct.UnitPrice;
                    orderProductsToInsert.add(orderProduct);
                }
            }
        }

        if (!orderProductsToInsert.isEmpty()) {
            insert orderProductsToInsert;
        }
    }
}