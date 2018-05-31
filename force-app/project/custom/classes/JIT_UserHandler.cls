global with sharing class JIT_UserHandler implements Auth.SamlJitHandler{

    @TestVisible
    private JIT_UserHandlerService service = new JIT_UserHandlerService();

    global User createUser(
        Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion
    ) {
        User u = service.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(
        Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion
    ) {
        service.updateUser(userId, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }


}
