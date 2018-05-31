@IsTest
private class COM_RecordTypeUtilsTest {
    static testMethod void shouldReturnRecordTypeForObjectTypeAndRecordTypeName() {
        Test.startTest();
        RecordType personAccountRecordType = COM_RecordTypeUtils.getRecordTypeByName(Account.class,
            COM_GlobalConstants.PERSON_ACCOUNT_RT);
        Test.stopTest();

        System.assert(personAccountRecordType != null, 'Record Type should be retrieved');
        System.assertEquals(COM_GlobalConstants.PERSON_ACCOUNT_RT, personAccountRecordType.DeveloperName,
            'Record Type retrieved should be person account record type');
    }

    static testMethod void shouldReturnException() {
        Test.startTest();
        RecordType personAccountRecordType;
        Exception e;
        try {
            personAccountRecordType = COM_RecordTypeUtils.getRecordTypeByName(Account.class,
                'Test');
        } catch (AuraHandledException ahe) {
            e = ahe;
        }
        Test.stopTest();

        System.assertEquals(null, personAccountRecordType, 'Record Type should not be retrieved');
        System.assert(e instanceof AuraHandledException, 'AuraHandledException should be thrown');
    }
}