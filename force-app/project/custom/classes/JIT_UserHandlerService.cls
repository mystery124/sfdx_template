public class JIT_UserHandlerService {

    public final static String MEMBER_OF = 'memberOf';
    public final static String DEFAULT_PROFILE_NAME = 'Default Access';
    public final static String GEO_GROUP_PATTERN = 'Application.CS_CRM.GeoComp';

    public final static Map<String,String> DEFAULT_USER_ATTRIBUTE_VALUES = new Map<String, String>{
        'locale'        => 'en_US',
        'timeZone'      => 'America/Los_Angeles',
        'emailEncoding' => 'ISO-8859-1'
    };

    @TestVisible
    private PermissionMappingRetriever permMappingRetriever = new PermissionMappingRetrieverImpl();

    public User createUser(
        Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion
    ) {
        User u = new User();
        handleUserJIT(true, u, attributes, federationIdentifier);
        return u;
    }

    public void updateUser(
        Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion
    ) {
        User u = [SELECT Id, Profile.Name FROM User WHERE FederationIdentifier = :federationIdentifier];
        handleUserJIT(false, u, attributes, federationIdentifier);
    }

    private void handleUserJIT(
        Boolean isCreate, User u, Map<String, String> attributes,
        String federationIdentifier
    ) {
        Map<String, String> attributesWithDefaults = getAttributesWithDefaults(isCreate, attributes);
        setUserFields(u, attributesWithDefaults);

        if(attributes.containsKey(MEMBER_OF)){
            setUserProfileIfChanged(u, attributes.get(MEMBER_OF));
        } else {
            throw new JitException('Missing AD groups');
        }

        if(isCreate) {
            u.EmailPreferencesAutoBcc = false;
            u = handleCreate(u, federationIdentifier);
        }

        if(!isCreate) {
            update u;
        } else {
            insert u;
        }

        assignUserToThePublicGroups(u, attributes.get(MEMBER_OF));
    }

    private void assignUserToThePublicGroups(User u, String groupSet) {
        Map<Id, Group> groupsForUser = getGroupsForUser(groupSet);
        List<GroupMember> groupAssignments = new List<GroupMember>();

        if (u.Id != null) {
            groupAssignments.addAll([
                SELECT Id, GroupId, UserOrGroupId
                FROM GroupMember
                WHERE UserOrGroupId = :u.Id
                AND GroupId IN (
                    SELECT Id 
                    FROM Group 
                    WHERE Type = 'Regular'
                )
            ]);
        }

        List<GroupMember> groupAssignmentsToRemove = new List<GroupMember>();
        List<GroupMember> groupAssignmentsToInsert = new List<GroupMember>();

        for (GroupMember groupAssignment : groupAssignments) {
            if (!groupsForUser.containsKey(groupAssignment.GroupId)) {
                groupAssignmentsToRemove.add(groupAssignment);
            } else {
                groupsForUser.remove(groupAssignment.GroupId);
            }
        }

        for (Id groupId : groupsForUser.keySet()) {
            groupAssignmentsToInsert.add(new GroupMember(
                GroupId       = groupId,
                UserOrGroupId = u.Id
            ));
        }
        
        if (!groupAssignmentsToRemove.isEmpty() || !groupAssignmentsToInsert.isEmpty()) {
            AssignUserToGroupsQueueableHandler job = 
                new AssignUserToGroupsQueueableHandler(groupAssignmentsToRemove, groupAssignmentsToInsert);
            System.enqueueJob(job);
        }
    }

    private Map<Id, Group> getGroupsForUser(String groupSet) {
        List<String> groupNames = getGroupsForGroupSet(groupSet);
        return new Map<Id, Group>([
            SELECT Id
            FROM Group
            WHERE DeveloperName IN :groupNames
            AND Type = 'Regular'
        ]);
    }

    private List<String> getGroupsForGroupSet(String groupSet){
        List<String> groupNames = new List<String>();
        List<String> userGroups = getUserGroups(groupSet);

        if (groupSet.countMatches(GEO_GROUP_PATTERN) == 1) {
            List<UserProvisioningPermissionMapping> mapping = findUserPermissionMappings(userGroups, false);
            for (UserProvisioningPermissionMapping uPM : mapping) {
                groupNames.add(uPM.groupName);
            }
        }

        return groupNames;
    }

    private List<UserProvisioningPermissionMapping> findUserPermissionMappings(
        List<String> userGroups, 
        Boolean breakIfFound
    ) {
        List<UserProvisioningPermissionMapping> userPermissionMappings = 
            new List<UserProvisioningPermissionMapping>();

        Boolean geoFound  = false;
        Boolean certFound = false;

        for (UserProvisioningPermissionMapping uPM : permMappingRetriever.findAttributePermissionMapping()) {
            geoFound  = false;
            certFound = false;

            for (String groupName : userGroups) {
                geoFound  = geoFound || Pattern.matches(uPM.geoCompGroup, groupName);
                certFound = certFound || Pattern.matches(uPM.certificationGroup, groupName);
            }

            if (geoFound && certFound) {
                userPermissionMappings.add(uPM);

                if (breakIfFound) {
                    break;
                }
            }
        }

        return userPermissionMappings;
    }

    private List<UserProvisioningPermissionMapping> findUserPermissionMappingsForAdmin(List<String> userGroups) {
        List<UserProvisioningPermissionMapping> userPermissionMappings = 
            new List<UserProvisioningPermissionMapping>();

        Boolean certFound = false;
        for (UserProvisioningPermissionMapping uPM : permMappingRetriever.findAttributePermissionMapping()) {
            certFound = false;
            
            if (String.isBlank(uPM.geoCompGroup)) {
                for (String groupName : userGroups) {
                    certFound = certFound || Pattern.matches(uPM.certificationGroup, groupName);
                }
            }

            if (certFound) {
                userPermissionMappings.add(uPM);
                break;
            }
        }

        return userPermissionMappings;
    }

    private Map<String, String> getAttributesWithDefaults(Boolean isCreate, Map<String, String> attributes) {
        Map<String, String> attributesWithDefaults = new Map<String, String>();
        attributesWithDefaults.putAll(attributes);

        if (isCreate) {
            for (String fieldName : DEFAULT_USER_ATTRIBUTE_VALUES.keySet()) {
                if (!attributesWithDefaults.containsKey(fieldName) || String.isBlank(attributesWithDefaults.get(fieldName))) {
                    attributesWithDefaults.put(fieldName, DEFAULT_USER_ATTRIBUTE_VALUES.get(fieldName));
                }
            }
        }

        return attributesWithDefaults;
    }

    private void setUserFields(User u, Map<String, String> attributesWithDefaults) {
        List<UserProvisioningFieldMapping__mdt> userProvisioningMappings = findAttributeFieldMapping();

        for (UserProvisioningFieldMapping__mdt mapping : userProvisioningMappings) {
            if (attributesWithDefaults.containsKey(mapping.SAMLAttributeName__c)
                && (String.isNotBlank(attributesWithDefaults.get(mapping.SAMLAttributeName__c)) || mapping.AllowBlank__c)
            ) {
                u.put(mapping.FieldAPIName__c, attributesWithDefaults.get(mapping.SAMLAttributeName__c));
            }
        }
    }

    private List<UserProvisioningFieldMapping__mdt> findAttributeFieldMapping(){
        List<UserProvisioningFieldMapping__mdt> userProvisioningMappings = [
            SELECT FieldAPIName__c, SAMLAttributeName__c, AllowBlank__c
              FROM UserProvisioningFieldMapping__mdt
        ];
        return userProvisioningMappings;
    }

    private User setUserProfileIfChanged(User u, String groupSet){
        String profileName = calculateProfileNameAndValidateAccess(groupSet);

        if(u.ProfileId == null ||  u.Profile.Name != profileName){
            List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
            if(profiles.isEmpty()){
                throw new JitException('Missing or invalid profile');
            }
            u.ProfileId = profiles.get(0).Id;
        }
        return u;
    }

    private String calculateProfileNameAndValidateAccess(String groupSet){
        String profileName      = DEFAULT_PROFILE_NAME;
        List<String> userGroups = getUserGroups(groupSet);
        List<UserProvisioningPermissionMapping> userPermissionMappings;

        if (groupSet.countMatches(GEO_GROUP_PATTERN) == 1) {
            userPermissionMappings = findUserPermissionMappings(userGroups, true);

            if (!userPermissionMappings.isEmpty()) {
                profileName = userPermissionMappings.get(0).profileName;
            }
        } else if (groupSet.countMatches(GEO_GROUP_PATTERN) == 0) {
            userPermissionMappings = findUserPermissionMappingsForAdmin(userGroups);

            if (!userPermissionMappings.isEmpty()) {
                profileName = userPermissionMappings.get(0).profileName;
            } else {
                throw new JitException('Login is not allowed');
            }
        }

        return profileName;
    }

    private List<String> getUserGroups(String groupSet){
        List<String> groups = new List<String>();
        List<String> groupDefinitions = groupSet.split('DC=com');
        for(String groupDefinition : groupDefinitions){
            groups.add(groupDefinition.substringBetween('CN=', ',OU='));
        }
        return groups;
    }

    private User handleCreate(User u, String federationIdentifier){
        System_Setting__c systemSetting = System_Setting__c.getInstance();
        String usernamePostfix = '';
        if (systemSetting != null && String.isNotBlank(systemSetting.UsernameOrgPostfix__c)) {
            usernamePostfix = systemSetting.UsernameOrgPostfix__c;
        }
        u.Username = federationIdentifier + usernamePostfix;
        u.Email = federationIdentifier;
        u.FederationIdentifier = federationIdentifier;
        return u;
    }

    public interface PermissionMappingRetriever{
        List<UserProvisioningPermissionMapping> findAttributePermissionMapping();
    }

    private class PermissionMappingRetrieverImpl implements PermissionMappingRetriever{
        private List<UserProvisioningPermissionMapping> userPermissionMappings;

        public List<UserProvisioningPermissionMapping> findAttributePermissionMapping() {
            if (userPermissionMappings == null) {
                List<UserProvisioningPermissionMapping__mdt> userPermissionMappingsMTD = [
                    SELECT Certification_Group__c, GeoComp_Group__c, ProfileName__c, Group_Name__c
                    FROM UserProvisioningPermissionMapping__mdt
                    ORDER BY Priority__c
                ];

                this.userPermissionMappings = new List<UserProvisioningPermissionMapping>();
                for (UserProvisioningPermissionMapping__mdt mtd : userPermissionMappingsMTD) {
                    this.userPermissionMappings.add(new UserProvisioningPermissionMapping(mtd));
                }
            }

            return this.userPermissionMappings;
        }
    }

    public class UserProvisioningPermissionMapping{
        public UserProvisioningPermissionMapping(){}

        public UserProvisioningPermissionMapping(UserProvisioningPermissionMapping__mdt mtdRecord){
            certificationGroup = mtdRecord.Certification_Group__c != null ? mtdRecord.Certification_Group__c : '';
            geoCompGroup       = mtdRecord.GeoComp_Group__c != null ? mtdRecord.GeoComp_Group__c : '';
            profileName        = mtdRecord.ProfileName__c;
            groupName          = mtdRecord.Group_Name__c;
        }

        public String certificationGroup;
        public String geoCompGroup;
        public String profileName;
        public String groupName;
    }

    public class AssignUserToGroupsQueueableHandler implements Queueable {
        private List<GroupMember> groupAssignmentsToRemove;
        private List<GroupMember> groupAssignmentsToInsert;

        public AssignUserToGroupsQueueableHandler(
            List<GroupMember> groupAssignmentsToRemove, 
            List<GroupMember> groupAssignmentsToInsert
        ) {
            this.groupAssignmentsToRemove = groupAssignmentsToRemove;
            this.groupAssignmentsToInsert = groupAssignmentsToInsert;
        }

        public void execute(QueueableContext context) {
            if (!groupAssignmentsToRemove.isEmpty()) {
                delete groupAssignmentsToRemove;
            }

            if (!groupAssignmentsToInsert.isEmpty()) {
                insert groupAssignmentsToInsert;
            }
        }
    }

    private class JitException extends Exception{}
}
