@IsTest
private class COM_DependentPicklistServiceTest {
    /*
    static testMethod void shouldReturnPicklistValuesForProductType( ) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();

        List<COM_BaseComponentService.PicklistValue> values;

        Test.startTest();
        System.runAs(u) {
            values = new COM_DependentPicklistService().getPicklistValuesForCurrentUsersRegion(
                Case.class.getName(), Case.Product_Type__c.getDescribe().getName());
        }
        Test.stopTest();

        System.assert(!values.isEmpty(), 'Values for Product Type for System Administrator should be retrieved');
    }

    static testMethod void shouldReturnEmptyList() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Read Only'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();

        List<COM_BaseComponentService.PicklistValue> values;

        Test.startTest();
        System.runAs(u) {
            values = new COM_DependentPicklistService().getPicklistValuesForCurrentUsersRegion(
                Case.class.getName(), Case.Product_Type__c.getDescribe().getName());
        }
        Test.stopTest();

        System.assert(values.isEmpty(), 'Values for Product Type for Read Only profile should not be retrieved');
    }

    static testMethod void shouldRetrieveValuesWhenCorrectRegionIsoCode() {
        Test.startTest();
        List<COM_BaseComponentService.PicklistValue> values = new COM_DependentPicklistService()
                .getPicklistValuesByApiAndRegion(
                    Case.sObjectType.getDescribe().getName(),
                    Case.Product_Type__c.getDescribe().getName(),
                    'US'
                );
        Test.stopTest();

        System.assert( ! values.isEmpty(), 'Values should be retrieved');
    }

    static testMethod void shouldRetrieveEmptyProductTypesWhenWrongIsoCode() {
        Test.startTest();
        List<COM_BaseComponentService.PicklistValue> values = new COM_DependentPicklistService()
                .getPicklistValuesByApiAndRegion(
                    Case.sObjectType.getDescribe().getName(),
                    Case.Product_Type__c.getDescribe().getName(),
                    'WRONG'
                );
        Test.stopTest();

        System.assert(values.isEmpty(), 'Values should be empty');
    }
    */
}