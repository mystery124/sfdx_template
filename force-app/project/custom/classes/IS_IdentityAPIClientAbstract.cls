public abstract class IS_IdentityAPIClientAbstract implements COM_CalloutClient {
    public final static String HEADER_AUTHORIZATION          = 'Authorization';
    public final static String HEADER_BASIC                  = 'Basic ';
    public final static String HEADER_X_APPID                = 'X--APP-ID';
    public final static String HEADER_VALUE_X_APPID          = IS_IdentityAPIConfigurationAccessor.getConfig('X_APP_ID__c');
    public final static String HEADER_CONTENT_TYPE           = 'Content-Type';
    public final static String HEADER_VALUE_APPLICATION_JSON = 'application/json';
    public final static String HEADER_ACCEPT_ENCODING        = 'Accept-Encoding';
    public final static String HEADER_VALUE_GZIP             = 'gzip, *';
    public final static String HEADER_X_UXID                 = 'X--UX-ID';
    public final static String HEADER_VALUE_X_UXID           = IS_IdentityAPIConfigurationAccessor.getConfig('X_UX_ID__c');

    public final static String IDENTITY_API_ENDPOINT_NAME = 'callout:IdentityAPI';
    public final static String IDNUSER_DETAIL_PATH        = '/user/';
    public final static String VIEW_ID                    = IS_IdentityAPIConfigurationAccessor.getConfig('View_ID__c');
    public final static String USERNAME_PATH              = '/username/';

    public final static Integer NO_DATA_FOUND_ERROR_CODE = 99807;

    public final static Integer DEFAULT_TIMEOUT = 120000;

    protected HttpRequest request;
    protected HttpResponse response;
    protected Type responseObjectType;

    public void doCallout() {
        this.response = new Http().send(request);
    }


    public Boolean isStatusCodeOk() {
        Boolean success = response.getStatusCode() == 200 || response.getStatusCode() == 202;

        if (response.getStatusCode() == 404) {
            IS_IdentityAPIClientContainer.IdentityErrorResponse errorResponse = 
                (IS_IdentityAPIClientContainer.IdentityErrorResponse) this.getErrorResponse();

            if (errorResponse.getStatus() == NO_DATA_FOUND_ERROR_CODE) {
                success = true;
            }
        }

        return success;
    }

    public Object getResponseObject() {
        String responseBody = response.getBody();
        return String.isBlank(responseBody) ? responseBody : JSON.deserializeUntyped(responseBody);
    }

    public COM_CalloutClientError getErrorResponse() {
        return (IS_IdentityAPIClientContainer.IdentityErrorResponse) 
            JSON.deserialize(response.getBody(), IS_IdentityAPIClientContainer.IdentityErrorResponse.class);
    }

    public String getRequestBody() {
        return request.getBody();
    }

    public String getResponseBody() {
        return response.getBody();
    }

    public Integer getResponseStatusCode() {
        return response.getStatusCode();
    }

    public HttpRequest createRequest(String method) {
        request = new HttpRequest();
        request.setMethod(method);
        request.setHeader(HEADER_X_APPID, HEADER_VALUE_X_APPID);
        request.setHeader(HEADER_AUTHORIZATION, HEADER_BASIC + '{!$Credential.Password}');
        request.setHeader(HEADER_CONTENT_TYPE, HEADER_VALUE_APPLICATION_JSON);
        request.setHeader(HEADER_ACCEPT_ENCODING, HEADER_VALUE_GZIP);
        request.setHeader(HEADER_X_UXID, HEADER_VALUE_X_UXID);
        request.setTimeout(DEFAULT_TIMEOUT);

        return request;
    }
}