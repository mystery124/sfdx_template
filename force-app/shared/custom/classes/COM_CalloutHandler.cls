public class COM_CalloutHandler {

    protected final Integer UNAUTHORIZED_STATUS_CODE = 401;

    public Object doCallout(COM_CalloutClient client) {
        Object response = null;

        try {

            client.doCallout();

            if(client.getResponseStatusCode() == UNAUTHORIZED_STATUS_CODE){
                client.doCallout();
            }

            if (client.isStatusCodeOk()) {
                response = client.getResponseObject();
            } else {
                COM_CalloutClientError error = client.getErrorResponse();
                logMessage(error.getMessage(), client.getResponseBody(), null);
                throw new CalloutHandlerException(error.getMessage());
            }

        } catch (CalloutException e) {
            String message = 'Callout failed: ' + client.getRequestBody();
            logMessage(message, client.getRequestBody(), e);
            throw new CalloutHandlerException(message, e);
        } catch (JSONException e) {
            String message = 'HTTP response cannot be deserialized: ' + client.getResponseBody();
            logMessage(message, client.getResponseBody(), e);
            throw new CalloutHandlerException(message, e);
        }

        return response;
    }

    private void logMessage(String message, String payLoad, Exception e) {
        new COM_Logger(COM_Logger.LogMode.MODE_REST).logMessage(
                COM_GlobalConstants.DEBUG_LVL_ERROR,
                COM_CalloutHandler.class.getName(),
                'doCallout(COM_CalloutClient client)',
                message,
                payLoad,
                e,
                0
        );
    }

    public class CalloutHandlerException extends Exception {}
}