@isTest
public class COM_CalloutMockHttp implements HttpCalloutMock {

    protected Map<String, Map<String, HttpResponse>> responseByEndpoint = new Map<String, Map<String, HttpResponse>>();
    protected Map<String, Type> exceptionsToFireByEndpoint = new Map<String, Type>();

    public COM_CalloutMockHttp(Integer code, String status, String body) {
        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatus(status);
        response.setStatusCode(code);

        addResponseByEndpoint('*', response);
    }

    public COM_CalloutMockHttp(HttpResponse response) {
        addResponseByEndpoint('*', response);
    }

    public COM_CalloutMockHttp(String endpoint, HttpResponse response) {
        addResponseByEndpoint(endpoint, response);
    }

    public COM_CalloutMockHttp(String endpoint, HttpResponse response, String method) {
        addResponseByEndpoint(endpoint, response, method);
    }

    public COM_CalloutMockHttp(String endpoint, String resourceName) {
        addResponseByEndpoint(endpoint, resourceName, 200, 'OK');
    }

    public COM_CalloutMockHttp(String endpoint, String resourceName, Integer responseCode, String responseStatus){
        addResponseByEndpoint (endpoint, resourceName, responseCode, responseStatus);
    }

    public void addResponseByEndpoint(String endpoint, HttpResponse response) {
        if (!responseByEndpoint.containsKey(endpoint)) {
            responseByEndpoint.put(endpoint, new Map<String, HttpResponse>());
        }

        responseByEndpoint.get(endpoint).put('*', response);
    }

    public void addResponseByEndpoint(String endpoint, HttpResponse response, String method) {
        if (!responseByEndpoint.containsKey(endpoint)) {
            responseByEndpoint.put(endpoint, new Map<String, HttpResponse>());
        }

        responseByEndpoint.get(endpoint).put(method, response);
    }

    public void addExceptionByEndpoint(String endpoint, Type exceptionType) {
        exceptionsToFireByEndpoint.put(endpoint, exceptionType);
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse response = findResponseByEndpointOrUseDefault(req);
        Type exceptionToFire  = findExceptionByEndpointOrUseDefault(req);
        System.debug(req.getEndpoint());
        if (exceptionToFire != null) {
            Exception e = (Exception) exceptionToFire.newInstance();
            e.setMessage('Exception Test Case');
            throw e;
        }

        return response;
    }

    private HttpResponse findResponseByEndpointOrUseDefault(HttpRequest req) {
        Map<String, HttpResponse> responseByMethod = responseByEndpoint.get('*');
        HttpResponse response;

        if (responseByMethod != null) {
            response = responseByMethod.get('*');
        }

        for (String key : responseByEndpoint.keySet()) {
            if (req.getEndpoint().contains(key)) {
                responseByMethod = responseByEndpoint.get(key);
                response = responseByMethod.containsKey(req.getMethod()) ?
                    responseByMethod.get(req.getMethod()) : responseByMethod.get('*');
            }
        }

        return response;
    }

    private Type findExceptionByEndpointOrUseDefault(HttpRequest req) {
        Type exceptionType = exceptionsToFireByEndpoint.get('*');
        for (String key: exceptionsToFireByEndpoint.keySet()) {
            if(req.getEndpoint().contains(key)){
                exceptionType = exceptionsToFireByEndpoint.get(key);
            }
        }

        return exceptionType;
    }

    private StaticResource getStaticResource(String name) {
        List<StaticResource> resources = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :name
        ];

        return resources.isEmpty() ? null : resources[0];
    }

    public void addResponseByEndpoint (String endpoint, String resourceName){
        if (!responseByEndpoint.containsKey(endpoint)) {
            responseByEndpoint.put(endpoint, new Map<String, HttpResponse>());
        }

        HttpResponse response = new HttpResponse();
        response.setStatus('OK');
        response.setStatusCode(200);
        response.setBodyAsBlob(getStaticResource(resourceName).Body);
        responseByEndpoint.get(endpoint).put('*', response);
    }

    public void addResponseByEndpoint (String endpoint, String resourceName, Integer responseCode, String responseStatus){
        if (!responseByEndpoint.containsKey(endpoint)) {
            responseByEndpoint.put(endpoint, new Map<String, HttpResponse>());
        }

        HttpResponse response = new HttpResponse();
        response.setStatus(responseStatus);
        response.setStatusCode(responseCode);
        response.setBodyAsBlob(getStaticResource(resourceName).Body);
        responseByEndpoint.get(endpoint).put('*', response);
    }
}