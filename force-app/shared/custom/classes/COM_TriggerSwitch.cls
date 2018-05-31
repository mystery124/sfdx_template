public with sharing class COM_TriggerSwitch {
    public static Boolean isTriggerActive(String triggerName){
        triggerName += '__c';
        Boolean isTriggerActive = (Boolean) TriggerSwitch__c.getInstance(UserInfo.getUserId()).get(triggerName);
        isTriggerActive = isTriggerActive == null ? true : isTriggerActive;
        return isTriggerActive;
    }
}
