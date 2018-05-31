
public class COM_DependentPicklistService extends COM_BaseComponentService{

    public List<PicklistValue> getPicklistValuesForCurrentUsersRegion(String objectApiName, String picklistApiName) {
        List<PicklistValue> picklistValues = new List<PicklistValue>();

        Profile userProfile = [
            SELECT Name
            FROM Profile
            WHERE Id = :UserInfo.getProfileId()
        ];

        List<Picklist_Mapping__mdt> picklists = [
            SELECT Picklist_Value__c
            FROM Picklist_Mapping__mdt
            WHERE Region__c IN (SELECT Region__c FROM COM_Profiles_Mapping__mdt WHERE Profile_Name__c = :userProfile.Name)
            AND Picklist_API_Name__c = :picklistApiName AND Object_API_Name__c = :objectApiName
        ];

        for(Picklist_Mapping__mdt pm : picklists) {
            picklistValues.add(new PicklistValue(pm.Picklist_Value__c, pm.Picklist_Value__c));
        }

        return picklistValues;
    }

    public List<PicklistValue> getPicklistValuesByApiAndRegion(String objectApiName, String picklistApiName, String region) {
        List<PicklistValue> picklistValues = new List<PicklistValue>();

        List<Picklist_Mapping__mdt> picklists = [
                SELECT Picklist_Value__c
                FROM Picklist_Mapping__mdt
                WHERE Region__c IN (SELECT Id FROM Region__mdt WHERE Region_Code__c = :region)
                    AND Picklist_API_Name__c = :picklistApiName
                    AND Object_API_Name__c = :objectApiName
        ];

        for(Picklist_Mapping__mdt pm : picklists) {
            picklistValues.add(new PicklistValue(pm.Picklist_Value__c, pm.Picklist_Value__c));
        }

        return picklistValues;
    }
}