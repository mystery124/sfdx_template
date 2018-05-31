@isTest
public with sharing class IS_IdentityAPIServiceTest {
    @isTest static void shouldReturnConsumerByUniqueConsumerId() {
        // Prepare test data
        String uniqueConsumerId = '70ffc4d2-e908-497e-b52e-c6a0d3346363';

        // Perform test
        Test.setMock(HttpCalloutMock.class, getStaticMockup(200, 'OK', 'IS_UpmIdSuccessResponse'));
        Test.startTest();

        IS_IdentityAPIService service = new IS_IdentityAPIService();
        IS_IdentityAPIClientContainer.ProfileRetrieveResponse result = service.retrieveConsumerProfileByUpmId(uniqueConsumerId);

        Test.stopTest();

        // Verify
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(uniqueConsumerId, result.upmId, 'UpmId should match');
    }

    @isTest static void shouldReturnConsumerByEmail() {
        // Prepare test data
        String email = 'dander214@gmail.com';

        // Perform test
        Test.setMock(HttpCalloutMock.class, getStaticMockup(200, 'OK', 'IS_EmailSuccessResponse'));
        Test.startTest();

        IS_IdentityAPIService service = new IS_IdentityAPIService();
        IS_IdentityAPIClientContainer.ProfileRetrieveResponse result = service.retrieveConsumerProfileByEmail(email);

        Test.stopTest();

        // Verify
        System.assertNotEquals(null, result, 'Result should not be null.');
    }

    @isTest static void shouldThrowExceptionForConsumerUniqueId() {
        // Prepare test data
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        String uniqueConsumerId = '2287393954';

        // Perform test
        Test.setMock(HttpCalloutMock.class, new UnauthorizedErrorResponse());
        Test.startTest();

        try {
            IS_IdentityAPIService service = new IS_IdentityAPIService();
            IS_IdentityAPIClientContainer.ProfileRetrieveResponse result = service.retrieveConsumerProfileByUpmId(uniqueConsumerId);
        } catch (COM_CalloutHandler.CalloutHandlerException e) {
            exceptionThrown  = true;
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();

        // Verify
        System.assert(exceptionThrown, 'Exception should be thrown');
    }

    @isTest static void shouldThrowExceptionForEmail() {
        // Prepare test data
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        String email            = 'modelo85@gmail.com';

        // Perform test
        Test.setMock(HttpCalloutMock.class, new UnauthorizedErrorResponse());
        Test.startTest();

        try {
            IS_IdentityAPIService service = new IS_IdentityAPIService();
            IS_IdentityAPIClientContainer.ProfileRetrieveResponse result = service.retrieveConsumerProfileByEmail(email);
        } catch (COM_CalloutHandler.CalloutHandlerException e) {
            exceptionThrown  = true;
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();

        // Verify
        System.assert(exceptionThrown, 'Exception should be thrown');
    }

    @isTest static void shouldResetPassword() {
        // Prepare test data
        String email = 'b.wayne@gotham.com';
        Boolean exceptionThrown = false;

        // Perform test
        Test.setMock(HttpCalloutMock.class, new COM_CalloutMockHttp(200, 'OK', ''));
        Test.startTest();

        try {
            IS_IdentityAPIService service = new IS_IdentityAPIService();
            service.resetPasswordForUser(email, false);
        } catch (Exception e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        // Verify
        System.assert(!exceptionThrown, 'Exception shouldnt be thrown');
    }

    @isTest static void shouldThrowErrorForResetPassword() {
        // Prepare test data
        String email = 'b.wayne@gotham.com';
        Boolean exceptionThrown = false;
        String exceptionMessage = '';        

        // Perform test
        Test.setMock(HttpCalloutMock.class, new UnauthorizedErrorResponse());
        Test.startTest();

        try {
            IS_IdentityAPIService service = new IS_IdentityAPIService();
            service.resetPasswordForUser(email, false);
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();

        // Verify
        System.assert(exceptionThrown, 'Exception should be thrown');
        System.assert(exceptionMessage.contains('Unauthorized'), 'Unauthorized Exception should be thrown');
    }

    static StaticResourceCalloutMock getStaticMockup(Integer code, String status, String staticResourceName) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(staticResourceName);
        mock.setStatusCode(code);
        mock.setStatus(status);
        mock.setHeader(IS_IdentitySearchAPIClientAbstract.HEADER_CONTENT_TYPE,
            IS_IdentitySearchAPIClientAbstract.HEADER_VALUE_APPLICATION_JSON);
        return mock;
    }

    class UnauthorizedErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(401);
            response.setStatus('Unauthorized');
            response.setBody('{"code": "UnauthorizedError","message": "Error: Failed to validate token - JWT expired"}');

            return response;
        }
    }
}