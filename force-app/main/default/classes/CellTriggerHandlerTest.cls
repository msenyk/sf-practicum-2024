@isTest
public class CellTriggerHandlerTest {
    // Utility method to create test data
    private static Cell__c createTestCell() {
        ParcelLocker__c locker = new ParcelLocker__c(UniqueNumber__c = 123, Location__Latitude__s = 37.7749, Location__Longitude__s = -122.4194);
        insert locker;
        return new Cell__c(ParcelLocker__c = locker.Id, Availability__c = 'Empty', Status__c = 'Closed'); // Include required fields other than Name, if any
    }

    @isTest
    static void testConstructor() {
        Test.startTest();
        CellTriggerHandler handler = new CellTriggerHandler(true, 10);
        Test.stopTest();

        System.assertNotEquals(null, handler, 'CellTriggerHandler instance should not be null');
        System.assertNotEquals(null, handler.helper, 'CellTriggerHelper instance should not be null');
    }

    @isTest
    static void testBeforeInsert() {
        // Arrange
        List<Cell__c> newCells = new List<Cell__c>{
                createTestCell()
        };

        CellTriggerHandler handler = new CellTriggerHandler(true, newCells.size());

        // Act
        Test.startTest();
        insert newCells;
        handler.beforeInsert(newCells);
        Test.stopTest();

        // Assert
        System.assertEquals(1, newCells.size(), 'One record should be processed.');
    }

    @isTest
    static void testBeforeUpdate() {
        // Arrange
        Cell__c cell = createTestCell();
        insert cell;

        Cell__c updatedCell = [SELECT Id FROM Cell__c WHERE Id = :cell.Id];
        updatedCell.addError('Mocking a before update scenario');

        List<Cell__c> oldCells = [SELECT Id FROM Cell__c WHERE Id = :cell.Id];
        List<Cell__c> newCells = new List<Cell__c>{updatedCell};

        Map<Id, Cell__c> oldCellsMap = new Map<Id, Cell__c>(oldCells);
        Map<Id, Cell__c> newCellsMap = new Map<Id, Cell__c>(newCells);

        CellTriggerHandler handler = new CellTriggerHandler(true, newCells.size());

        // Act
        Test.startTest();
        try {
            update updatedCell;
        } catch (DmlException e) {
            // Expected as we added an error
        }
        handler.beforeUpdate(oldCells, newCells, oldCellsMap, newCellsMap);
        Test.stopTest();

        // Assert
        System.assertEquals(1, newCells.size(), 'One record should be processed.');
    }

    @isTest
    static void testBeforeDelete() {
        // Arrange
        Cell__c cell = createTestCell();
        insert cell;

        List<Cell__c> oldCells = [SELECT Id FROM Cell__c WHERE Id = :cell.Id];
        Map<Id, Cell__c> oldCellsMap = new Map<Id, Cell__c>(oldCells);

        CellTriggerHandler handler = new CellTriggerHandler(true, oldCells.size());

        // Act
        Test.startTest();
        delete oldCells;
        handler.beforeDelete(oldCells, oldCellsMap);
        Test.stopTest();

        // Assert
        System.assertEquals(1, oldCells.size(), 'One record should be deleted.');
    }

    @isTest
    static void testAfterInsert() {
        // Arrange
        List<Cell__c> newCells = new List<Cell__c>{
                createTestCell()
        };

        Map<Id, Cell__c> newCellsMap = new Map<Id, Cell__c>();

        CellTriggerHandler handler = new CellTriggerHandler(false, newCells.size());

        // Act
        Test.startTest();
        insert newCells;
        for (Cell__c cell : newCells) {
            newCellsMap.put(cell.Id, cell);
        }
        handler.afterInsert(newCells, newCellsMap);
        Test.stopTest();

        // Assert
        System.assertEquals(newCells.size(), newCellsMap.size(), 'Processed record counts should match.');
    }

    @isTest
    static void testAfterUpdate() {
        // Arrange
        Cell__c cell = createTestCell();
        insert cell;

        Cell__c updatedCell = [SELECT Id FROM Cell__c WHERE Id = :cell.Id];

        List<Cell__c> oldCells = [SELECT Id FROM Cell__c WHERE Id = :cell.Id];
        List<Cell__c> newCells = new List<Cell__c>{updatedCell};

        Map<Id, Cell__c> oldCellsMap = new Map<Id, Cell__c>(oldCells);
        Map<Id, Cell__c> newCellsMap = new Map<Id, Cell__c>(newCells);

        CellTriggerHandler handler = new CellTriggerHandler(false, newCells.size());

        // Act
        Test.startTest();
        update updatedCell;
        handler.afterUpdate(oldCells, newCells, oldCellsMap, newCellsMap);
        Test.stopTest();

        // Assert
        System.assertEquals(1, newCells.size(), 'The number of records updated should be correct.');
    }

    @isTest
    static void testAfterDelete() {
        // Arrange
        Cell__c cell = createTestCell();
        insert cell;

        List<Cell__c> oldCells = [SELECT Id FROM Cell__c WHERE Id = :cell.Id];
        Map<Id, Cell__c> oldCellsMap = new Map<Id, Cell__c>(oldCells);

        CellTriggerHandler handler = new CellTriggerHandler(false, oldCells.size());

        // Act
        Test.startTest();
        delete oldCells;
        handler.afterDelete(oldCells, oldCellsMap);
        Test.stopTest();

        // Assert
        System.assertEquals(1, oldCells.size(), 'One record should be deleted.');
    }

    @isTest
    static void testAfterUndelete() {
        // Arrange
        Cell__c cell = createTestCell();
        insert cell;
        delete cell;
        undelete cell;

        List<Cell__c> newCells = [SELECT Id FROM Cell__c WHERE Id = :cell.Id];
        Map<Id, Cell__c> newCellsMap = new Map<Id, Cell__c>(newCells);

        CellTriggerHandler handler = new CellTriggerHandler(false, newCells.size());

        // Act
        Test.startTest();
        handler.afterUndelete(newCells, newCellsMap);
        Test.stopTest();

        // Assert
        System.assertEquals(1, newCells.size(), 'One record should be undeleted.');
    }
}