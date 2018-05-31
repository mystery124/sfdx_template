public class COM_RecordTypeUtils {

    private static Map<String, RecordType> recordTypes = new Map<String, RecordType>();

    //TODO - there is new describe functionality which can be used here
    public static RecordType getRecordTypeByName(Type objType, String rtName) {
        String objName = objType.getName();
        RecordType recordType;
        if(recordTypes.containsKey(rtName)){
            recordType = recordTypes.get(rtName);
        } else {
            try{
                recordType = [
                    SELECT DeveloperName
                    FROM RecordType
                    WHERE SObjectType = :objName AND DeveloperName = :rtName
                ];
                recordTypes.put(rtName, recordType);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return recordType;
    }
}