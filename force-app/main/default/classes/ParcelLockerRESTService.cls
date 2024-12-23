public class ParcelLockerRESTService {

    private static final String BASE_URL = 'callout:ParcelLockerRESTService';
    
    // Opening a cell
    public Boolean openCell(Integer lockerId, String cellId) {
        try {
            // Create an instance of the Http request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BASE_URL + '/locker/' + lockerId + '/cell/' + cellId + '/open');
            request.setMethod('POST');
			
            // Send the HTTP request and receive the response from REST API
            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                return true;
            }
        } catch (Exception e) {
            System.debug('Error opening cell: ' + e.getMessage());
        }
        return false;
    }
 
    // Closing a cell
    public Boolean closeCell(Integer lockerId, String cellId) {
        try {
            // Create an instance of the Http request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BASE_URL + '/locker/' + lockerId + '/cell/' + cellId + '/close');
            request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json');
            request.setBody(Json.serialize(new Map<String, String>{'pin' => 'xxxxxx'}));
            
            // Send the HTTP request and receive the response from REST API
            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                return true;
            }
        } catch (Exception e) {
            System.debug('Error closing cell: ' + e.getMessage());
        }
        return false;
    }
    
    // Setting a PIN code
    public Boolean setPIN(Integer lockerId, String cellId, String pin) {
        try {
            // Create an instance of the Http request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BASE_URL + '/locker/' + lockerId + '/cell/' + cellId + '/setPIN');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(Json.serialize(new Map<String, String>{'pin' => pin}));
				
            // Send the HTTP request and receive the response from REST API
            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                return true;
            }
        } catch (Exception e) {
            System.debug('Error setting PIN: ' + e.getMessage());
        }
        return false;
    }
}