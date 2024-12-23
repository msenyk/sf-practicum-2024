// Mock-class for HTTP requests.
public class ParcelLockerMock implements HttpCalloutMock {
    private HttpResponse mockResponse;

    public ParcelLockerMock(HttpResponse response) {
        this.mockResponse = response;
    }

    public HttpResponse respond(HttpRequest req) {
        return mockResponse;
    }
}