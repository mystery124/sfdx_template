@IsTest
public class COM_CalloutMockWebservice implements WebServiceMock{

    protected Object mockedResponse;
    public Type exceptionToFire = null;//set the exception type if exception simulation needed

    public COM_CalloutMockWebservice(Object mockedResponse){
        this.mockedResponse = mockedResponse;
    }

    public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
    ) {
        if (exceptionToFire != null) {
            Exception e = (Exception) exceptionToFire.newInstance();
            e.setMessage('Exception Test Case');
            throw e;
        }

        response.put('response_x', mockedResponse);
    }
}