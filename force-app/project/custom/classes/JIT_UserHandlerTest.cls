@IsTest
private with sharing class JIT_UserHandlerTest {

    private static Map<String, String> getAttributes(){
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('firstName', 'John');
        attributes.put('lastName', 'Doe');
        attributes.put('alias', 'JDoe');
        attributes.put('locale', 'en_US');
        attributes.put('timeZone', 'America/Los_Angeles');
        attributes.put('emailEncoding', 'ISO-8859-1');
        attributes.put(JIT_UserHandlerService.MEMBER_OF,
            'CN=Application.CS_CRM.GeoComp.NA_NKE,OU=Application,OU=Groups,DC=ad,DC=,DC=com,'+
            'CN=Application.CS_CRM.Certificate.L3-ESA_Com-NA,OU=Application,OU=Groups,DC=ad,DC=,DC=com'
        );
        return attributes;
    }

    @isTest static void shouldCreateNewUser() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        String federationId = 'test@notexistingOrganisation.com';
        Map<String, String> attributes = getAttributes();

        //when
        JIT_UserHandler handler = new JIT_UserHandler();
        handler.service.permMappingRetriever = new PermissionMappingRetrieverTest();
        Test.startTest();
        User u = handler.createUser(null, null, null, federationId, attributes, null);
        Test.stopTest();

        //then
        System.assertEquals(federationId, u.FederationIdentifier);
        System.assertNotEquals(null, u.Id);
    }

    @isTest static void shouldNotCreateNewUserWithSameFederationId() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;

        //when
        JIT_UserHandler handler = new JIT_UserHandler();
        Map<String, String> attributes = getAttributes();
        Test.startTest();
        User result;
        try{
            
            result = handler.createUser(null, null, null, federationId, attributes, null);

        //then
            System.assert(false, 'Should not allow to create user with existing FederationIdentifier');
        } catch(Exception ex){
            System.assertEquals(null, result);
        }
        Test.stopTest();
    }

    @isTest static void shouldFailCauseOfMissingADGroupAttribute() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;
        JIT_UserHandler handler = new JIT_UserHandler();
        Map<String, String> attributes = getAttributes();

        //when
        attributes.remove(JIT_UserHandlerService.MEMBER_OF);
        Test.startTest();
        User result;
        try{
            result = handler.createUser(null, null, null, federationId, attributes, null);

        //then
            System.assert(false, 'Should not allow to create user with existing FederationIdentifier');
        } catch(Exception ex){
            System.assertEquals(null, result);
        }
        Test.stopTest();
    }

    @isTest static void shouldFailCauseOfMissingADGeoGroup() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;
        JIT_UserHandler handler = new JIT_UserHandler();
        Map<String, String> attributes = getAttributes();

        //when
            attributes.put(JIT_UserHandlerService.MEMBER_OF, 
             'CN=Application.CS_CRM.Certificate.L3-ESA_Com-NA,OU=Application,OU=Groups,DC=ad,DC=,DC=com'
             );
        Test.startTest();
        User result;
        try{
            result = handler.createUser(null, null, null, federationId, attributes, null);

        //then
            System.assert(false, 'Should not allow to create user with existing FederationIdentifier');
        } catch(Exception ex){
            System.assertEquals(null, result);
        }
        Test.stopTest();
    }

    @isTest static void shouldSetProfileToDefaultCauseOfAmbiousGeoADGroup() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;
        JIT_UserHandler handler = new JIT_UserHandler();
        Map<String, String> attributes = getAttributes();

        //when
        attributes.put(JIT_UserHandlerService.MEMBER_OF, 
             'CN=Application.CS_CRM.GeoComp.NA_NKE,OU=Application,OU=Groups,DC=ad,DC=,DC=com,'+
             'CN=Application.CS_CRM.GeoComp.NA_CVG,OU=Application,OU=Groups,DC=ad,DC=,DC=com'
             );
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            handler.updateUser(null, null, null, null, federationId, attributes, null);
        }
        Test.stopTest();

        //then
        User result = [SELECT Profile.Name FROM User WHERE FederationIdentifier = :federationId];
        System.assertEquals(JIT_UserHandlerService.DEFAULT_PROFILE_NAME, result.Profile.Name);
    }

    @isTest static void shouldSetProfileCorrectly() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;
        JIT_UserHandler handler = new JIT_UserHandler();
        handler.service.permMappingRetriever = new PermissionMappingRetrieverTest();
        Map<String, String> attributes = getAttributes();

        //when
        attributes.put(JIT_UserHandlerService.MEMBER_OF, 
             'CN=Application.CS_CRM.GeoComp.NA_NKE,OU=Application,OU=Groups,DC=ad,DC=,DC=com,'+
             'CN=Application.CS_CRM.Certificate.L3-ESA_Com-NA,OU=Application,OU=Groups,DC=ad,DC=,DC=com'
             );
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            handler.updateUser(null, null, null, null, federationId, attributes, null);
        }
        Test.stopTest();

        //then
        User result = [SELECT Profile.Name FROM User WHERE FederationIdentifier = :federationId];
        System.assertNotEquals(p.Name, result.Profile.Name);
    }

    @isTest static void shouldUpdateExistingUser() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id FROM Profile WHERE Name = :JIT_UserHandlerService.DEFAULT_PROFILE_NAME];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;

        String firstName = 'John';
        String lastName = 'Doe';

        //when
        JIT_UserHandler handler = new JIT_UserHandler();
        handler.service.permMappingRetriever = new PermissionMappingRetrieverTest();
        Map<String, String> attributes = getAttributes();

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            handler.updateUser(null, null, null, null, federationId, attributes, null);
        }
        Test.stopTest();

        //then
        User result = [SELECT FirstName, LastName FROM User WHERE FederationIdentifier = :federationId];
        System.assertEquals(firstName, result.FirstName);
        System.assertEquals(lastName, result.LastName);
    }

    @isTest static void shouldSetAdminProfileCorrectly() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;
        JIT_UserHandler handler = new JIT_UserHandler();
        handler.service.permMappingRetriever = new PermissionMappingRetrieverAdminTest();
        Map<String, String> attributes = getAttributes();

        //when
        attributes.put(JIT_UserHandlerService.MEMBER_OF, 
            'CN=Application.CS_CRM.Certificate.SysAdmin,OU=Application,OU=Groups,DC=ad,DC=,DC=com'
        );
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            handler.updateUser(null, null, null, null, federationId, attributes, null);
        }
        Test.stopTest();

        //then
        User result = [SELECT Profile.Name FROM User WHERE FederationIdentifier = :federationId];
        System.assertEquals(p.Name, result.Profile.Name);
    }

    @isTest static void shouldAssignUserToTheGroup() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;
        String groupName = 'CVG_Mgmt';
        JIT_UserHandler handler = new JIT_UserHandler();
        handler.service.permMappingRetriever = new PermissionMappingRetrieverTest();
        Map<String, String> attributes = getAttributes();
        attributes.put(JIT_UserHandlerService.MEMBER_OF, 
            'CN=Application.CS_CRM.GeoComp.NA_NKE,OU=Application,OU=Groups,DC=ad,DC=,DC=com,'+
            'CN=Application.CS_CRM.Certificate.L3-ESA_Com-NA,OU=Application,OU=Groups,DC=ad,DC=,DC=com'
        );

        //when
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            handler.updateUser(null, null, null, null, federationId, attributes, null);
        }
        Test.stopTest();

        //then
        User result = [SELECT Profile.Name FROM User WHERE FederationIdentifier = :federationId];
        System.assertNotEquals(p.Name, result.Profile.Name);

        List<GroupMember> groupAssignments = [
            SELECT Id, GroupId, UserOrGroupId
            FROM GroupMember
            WHERE UserOrGroupId = :result.Id
            AND GroupId IN (
                SELECT Id 
                FROM Group 
                WHERE Type = 'Regular'
                AND DeveloperName = :groupName
            )
        ];
        System.assert(!groupAssignments.isEmpty(), 'User should be assigned to the group');
    }

    @isTest static void shouldRemoveUserFromTheGroup() {
        //given
        new COM_TestHelper.SystemSettingBuilder().build().save();
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User u = new COM_TestHelper.UserBuilder().build().withProfileId(p.Id).getRecord();
        String federationId = 'test@notexistingOrganisation.com';
        u.FederationIdentifier = federationId;
        insert u;
        String groupName = 'CVG_Mgmt';
        Group g = [
            SELECT Id 
            FROM Group 
            WHERE Type = 'Regular'
            AND DeveloperName != :groupName
            LIMIT 1
        ];
        JIT_UserHandler handler = new JIT_UserHandler();
        handler.service.permMappingRetriever = new PermissionMappingRetrieverTest();
        Map<String, String> attributes = getAttributes();
        attributes.put(JIT_UserHandlerService.MEMBER_OF, 
            'CN=Application.CS_CRM.GeoComp.NA_NKE,OU=Application,OU=Groups,DC=ad,DC=,DC=com,'+
            'CN=Application.CS_CRM.Certificate.L3-ESA_Com-NA,OU=Application,OU=Groups,DC=ad,DC=,DC=com'
        );

        //when
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new GroupMember(
                GroupId = g.Id,
                UserOrGroupId = u.Id
            );

            handler.updateUser(null, null, null, null, federationId, attributes, null);
        }
        Test.stopTest();

        //then
        User result = [SELECT Profile.Name FROM User WHERE FederationIdentifier = :federationId];
        System.assertNotEquals(p.Name, result.Profile.Name);

        List<GroupMember> groupAssignments = [
            SELECT Id, GroupId, UserOrGroupId
            FROM GroupMember
            WHERE UserOrGroupId = :result.Id
            AND GroupId IN (
                SELECT Id 
                FROM Group 
                WHERE Type = 'Regular'
                AND DeveloperName != :groupName
            )
        ];
        System.assert(groupAssignments.isEmpty(), 'User should be removed from the previous group');
    }

    private class PermissionMappingRetrieverTest implements JIT_UserHandlerService.PermissionMappingRetriever{
        public List<JIT_UserHandlerService.UserProvisioningPermissionMapping> findAttributePermissionMapping(){
            List<JIT_UserHandlerService.UserProvisioningPermissionMapping> userPermissiongMappings =
                new List<JIT_UserHandlerService.UserProvisioningPermissionMapping>();
            JIT_UserHandlerService.UserProvisioningPermissionMapping userPermissiongMapping =
                new JIT_UserHandlerService.UserProvisioningPermissionMapping();
            userPermissiongMapping.certificationGroup = 'Application.CS_CRM.Certificate.L3-ESA_Com-NA';
            userPermissiongMapping.geoCompGroup = 'Application.CS_CRM.GeoComp.NA_NKE';
            userPermissiongMapping.profileName = JIT_UserHandlerService.DEFAULT_PROFILE_NAME;
            userPermissiongMapping.groupName = 'CVG_Mgmt';
            userPermissiongMappings.add(userPermissiongMapping);
            return userPermissiongMappings;
        }
    }

    private class PermissionMappingRetrieverAdminTest implements JIT_UserHandlerService.PermissionMappingRetriever{
        public List<JIT_UserHandlerService.UserProvisioningPermissionMapping> findAttributePermissionMapping(){
            List<JIT_UserHandlerService.UserProvisioningPermissionMapping> userPermissiongMappings =
                new List<JIT_UserHandlerService.UserProvisioningPermissionMapping>();
            JIT_UserHandlerService.UserProvisioningPermissionMapping userPermissiongMapping =
                new JIT_UserHandlerService.UserProvisioningPermissionMapping();
            userPermissiongMapping.certificationGroup = 'Application.CS_CRM.Certificate.SysAdmin';
            userPermissiongMapping.geoCompGroup = '';
            userPermissiongMapping.profileName = 'System Administrator';
            userPermissiongMapping.groupName = '';
            userPermissiongMappings.add(userPermissiongMapping);
            return userPermissiongMappings;
        }
    }
}
