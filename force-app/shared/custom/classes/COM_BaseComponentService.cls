public abstract class COM_BaseComponentService {

    protected List<PicklistValue> getPicklistValues(String objectName, String fieldName){
        List<PicklistValue> options = new List<PicklistValue>();
        Schema.DescribeFieldResult fieldResult =
                Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            options.add(new PicklistValue(f.getLabel(), f.getValue()));
        }
        return options;
    }

    public class PicklistValue{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public Boolean selected {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public PicklistValue(String label, String value){
            this.value = value;
            this.label = label;
            this.selected = false;
        }
    }
}