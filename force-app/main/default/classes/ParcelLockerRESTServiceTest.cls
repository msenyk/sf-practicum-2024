@isTest
public class ParcelLockerRESTServiceTest {
    @isTest
    static void testOpenCell() {
        // Arrange
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"lockerId":1234, "cellId":"C-002", "status":"open", "pin":123456"}');
        Test.setMock(HttpCalloutMock.class, new ParcelLockerMock(mockResponse));
       
        ParcelLockerRESTService service = new ParcelLockerRESTService();
        
        // Act
        Test.startTest();
        Boolean result = service.openCell(1234, 'C-002');
        Test.stopTest();

        // Assert
        System.assertEquals(true, result, 'Cell should open successfully.');
    }

    @isTest
    static void testCloseCell() {
        // Arrange
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"lockerId":1234, "cellId":"C-002", "status":"closed", "pin":"123456"}');
        Test.setMock(HttpCalloutMock.class, new ParcelLockerMock(mockResponse));

        ParcelLockerRESTService service = new ParcelLockerRESTService();
        
        // Act
        Test.startTest();
        Boolean result = service.closeCell(1234, 'C-002');
        Test.stopTest();
		
        // Assert
        System.assertEquals(true, result, 'Cell should close successfully.');
    }

    @isTest
    static void testSetPIN() {
        // Arrange
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"lockerId":1234, "cellId":"C-002", "status":"open", "pin":789101"}');
        Test.setMock(HttpCalloutMock.class, new ParcelLockerMock(mockResponse));

        ParcelLockerRESTService service = new ParcelLockerRESTService();
        
        // Act
        Test.startTest();
        Boolean result = service.setPIN(1234, 'C-002', '789101');
        Test.stopTest();
		
        // Assert
        System.assertEquals(true, result, 'PIN should be set successfully.');
    }
    
    @isTest
    static void testOpenCell_Exeption() {
        // Arrange
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(404);
        mockResponse.setBody('{"detail":"Cell by ID: C-003 not found (locker ID: 1234)"}');
        Test.setMock(HttpCalloutMock.class, new ParcelLockerMock(mockResponse));

        ParcelLockerRESTService service = new ParcelLockerRESTService();
        
        // Act
        Test.startTest();
        Boolean result = service.openCell(1234, 'C-003');
        Test.stopTest();
       
        // Assert
        System.assertEquals(false, result, 'Method should return false on error.');
    }
    
    @isTest
    static void testCloseCell_Exeption() {
        // Arrange
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(404);
        mockResponse.setBody('{"detail":"Cell by ID: C-003 not found (locker ID: 1234)"}');
        Test.setMock(HttpCalloutMock.class, new ParcelLockerMock(mockResponse));

        ParcelLockerRESTService service = new ParcelLockerRESTService();
        
        // Act
        Test.startTest();
        Boolean result = service.closeCell(1234, 'C-003');
       	Test.stopTest();
        
        // Assert
        System.assertEquals(false, result, 'Method should return false on error.');
    }
    
    @isTest
    static void testSetPIN_Exeption() {
        // Arrange
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(404);
        mockResponse.setBody('{"detail":"Cell by ID: C-003 not found (locker ID: 1234)"}');
        Test.setMock(HttpCalloutMock.class, new ParcelLockerMock(mockResponse));

        ParcelLockerRESTService service = new ParcelLockerRESTService();
        
        // Act
        Test.startTest();
        Boolean result = service.setPIN(1234, 'C-003', '123456');
        Test.stopTest();
       
        // Assert
        System.assertEquals(false, result, 'Method should return false on error.');
    }
}