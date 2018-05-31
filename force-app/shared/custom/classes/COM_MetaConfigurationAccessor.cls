public class COM_MetaConfigurationAccessor {

    protected String metadataObjectName;
    protected String configDeveloperName;

    public COM_MetaConfigurationAccessor(String metadataObjectName, String configDeveloperName) {
        this.metadataObjectName = metadataObjectName;
        this.configDeveloperName = configDeveloperName;
    }
 
    public Map<String, String> buildConfigMap() {
        List<String> configFields = getConfigurationFields();
        List<SObject> configurations = Database.query(
                'SELECT ' + String.join(configFields, ',') + ', DeveloperName FROM ' + metadataObjectName + ' WHERE DeveloperName = :configDeveloperName'
        );

        Map<String, String> valueByType = new Map<String, String>();
        if( ! configurations.isEmpty()){
            SObject config = configurations[0];
            for(String fieldName: configFields){
                valueByType.put(fieldName, String.valueOf(config.get(fieldName)));
            }
        }

        return valueByType;
    }

    private List<String> getConfigurationFields() {
        List<String> fields = new List<String>();
        for(Schema.SObjectField field: Schema.getGlobalDescribe().get(metadataObjectName).getDescribe().fields.getMap().values()){
            String fieldName = String.valueOf(field);
            if(fieldName.endsWith('__c')){
                fields.add(fieldName);
            }
        }
        return fields;
    }
}