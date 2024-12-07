public without sharing class ParcelLockerTriggerHelper {
    public ParcelLockerTriggerHelper() {}
    public void checkUniqueNames(List<ParcelLocker__c> newRecords) {
        Map<String, Integer> nameCountMap = new Map<String, Integer>();
        for (ParcelLocker__c pl : newRecords) {
            if (pl.Name != null) {
                if (!nameCountMap.containsKey(pl.Name)) {
                    nameCountMap.put(pl.Name, 0);
                }
                nameCountMap.put(pl.Name, nameCountMap.get(pl.Name) + 1);
            }
        }      
        // Check existing records for duplicate names
        Map<String, Id> existingNamesMap = new Map<String, Id>();
        for (ParcelLocker__c pl : [SELECT Name FROM ParcelLocker__c WHERE Name IN :nameCountMap.keySet()]) {
            existingNamesMap.put(pl.Name, pl.Id);
        }
        // Check if the names are unique
        for (ParcelLocker__c pl : newRecords) {
            if (pl.Name != null) {
                // Check duplicates in inserted records
                if (nameCountMap.get(pl.Name) > 1) {
                    pl.addError('Parcel locker with the name "' + pl.Name + '" is not unique among the entries being inserted.');
                }
                // Check duplicates in existing records
                else if (existingNamesMap.containsKey(pl.Name) && existingNamesMap.get(pl.Name) != pl.Id) {
                    pl.addError('Parcel Locker with the name "' + pl.Name + '" already exists.');
                }
            }
        }
    }
}