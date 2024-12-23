trigger CellPINTrigger on Cell__c (before update) {
    for (Cell__c cell : Trigger.new) {
        if (cell.Availability__c == 'Full' && Trigger.oldMap.get(cell.Id).Availability__c != 'Full' && cell.Status__c == 'Closed' && Trigger.oldMap.get(cell.Id).Status__c != 'Closed' && String.isBlank(cell.Pin__c)) {
            String pin = GeneratorPin.generateUniquePin();
            cell.Pin__c = pin;
        }
    }
}