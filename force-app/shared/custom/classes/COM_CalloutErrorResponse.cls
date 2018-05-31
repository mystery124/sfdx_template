public class COM_CalloutErrorResponse implements COM_CalloutClientError{

    public String httpStatus;
    public String message;
    public String status;

    public COM_CalloutErrorResponse(String status, String message){
        this.status = status;
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}