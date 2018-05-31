
public interface COM_CalloutClient {

    void doCallout();

    Boolean isStatusCodeOk();

    Integer getResponseStatusCode();

    Object getResponseObject();

    COM_CalloutClientError getErrorResponse();

    String getRequestBody();

    String getResponseBody();
}