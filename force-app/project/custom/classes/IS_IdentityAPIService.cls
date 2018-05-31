public class IS_IdentityAPIService {

    public IS_IdentityAPIClientContainer.ProfileRetrieveResponse retrieveConsumerProfileByUpmId(String upmId) {
        COM_CalloutHandler handler = new COM_CalloutHandler();
        IS_IdentityAPIClientContainer.ProfileRetrieveByUpmId client = 
            new IS_IdentityAPIClientContainer.ProfileRetrieveByUpmId(upmId);
        Map<String, Object> res = (Map<String, Object>) handler.doCallout(client);
        IS_IdentityAPIClientContainer.ProfileRetrieveResponse response;

        if (!res.containsKey('errors')) {
            response = new IS_IdentityAPIClientContainer.ProfileRetrieveResponse(res);
        }

        return response;
    }

    public IS_IdentityAPIClientContainer.ProfileRetrieveResponse retrieveConsumerProfileByEmail(String email) {
        COM_CalloutHandler handler = new COM_CalloutHandler();
        IS_IdentityAPIClientContainer.ProfileRetrieveByEmail client = 
            new IS_IdentityAPIClientContainer.ProfileRetrieveByEmail(email);
        Map<String, Object> res = (Map<String, Object>) handler.doCallout(client);
        IS_IdentityAPIClientContainer.ProfileRetrieveResponse response;

        if (!res.containsKey('errors')) {
            Map<String, Object> resValue = (Map<String, Object>) res.values()[0];
            response = new IS_IdentityAPIClientContainer.ProfileRetrieveResponse(resValue);
        }

        return response;
    }


}