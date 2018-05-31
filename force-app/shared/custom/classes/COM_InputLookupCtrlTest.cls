@IsTest
public class COM_InputLookupCtrlTest {
    private final static String FAKE_ACCOUNT_ID = '001J000001zCrAlIBK';

    @IsTest static void shouldThrowAuraExceptionWhenWrongSobject() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            List<COM_InputLookupService.LookupRecord> results = COM_InputLookupCtrl.searchSObjectsByName('wrongData', '');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'AuraHandledException should be thrown when wrong sObject');
    }

    @IsTest static void shouldThrowAuraExceptionWhenRecordWithSpecifiedIdNotExist() {
        Boolean exceptionThrown = false;
        String exceptionMessage = '';

        Test.startTest();
        try {
            COM_InputLookupService.LookupRecord results = COM_InputLookupCtrl.getSObjectById('Account', FAKE_ACCOUNT_ID);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getCause().getMessage();
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'AuraHandledException should be thrown when wrong Id');
        System.assertEquals('InputLookupDefaultNotExists', exceptionMessage, 'Lookup has wrong exception message when no records found');
    }
/*
    @IsTest static void shouldReturnLookupRecordWithProperValues() {
        Account acc = new COM_TestHelper.AccountBuilder().build().withFirstLastName('Tester', 'Tester').save().getRecord();

        Test.startTest();
        COM_InputLookupService.LookupRecord results = COM_InputLookupCtrl.getSObjectById('Account', acc.Id);
        Test.stopTest();

        System.assertEquals(acc.FirstName + ' ' + acc.LastName, results.name, 'LookupRecord has wrong name value');
        System.assertEquals(acc.Id, results.id, 'LookupRecord has wrong id value');
    }

    @IsTest static void shouldReturnSearchResultsByName() {
        List<Account> accounts = new List<Account>{
                new COM_TestHelper.AccountBuilder().build().withFirstLastName('Tester1', 'Tester1').getRecord(),
                new COM_TestHelper.AccountBuilder().build().withFirstLastName('Tester2', 'Tester2').getRecord(),
                new COM_TestHelper.AccountBuilder().build().withFirstLastName('Tester3', 'Tester3').getRecord(),
                new COM_TestHelper.AccountBuilder().build().withFirstLastName('Tester4', 'Tester4').getRecord()
        };
        insert accounts;

        Test.startTest();
        List<COM_InputLookupService.LookupRecord> results = COM_InputLookupCtrl.searchSObjectsByName('Account', 'test');
        Test.stopTest();

        System.assertEquals(4, results.size(), 'Search results should contain 4 records');
    }
    */
}