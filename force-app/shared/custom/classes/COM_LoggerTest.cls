@IsTest
public class COM_LoggerTest {
    @IsTest
    private static void testLogging() {
        insertSettingForLogger(true, true, true, 1);
        COM_Logger logger = new COM_Logger();
        
        Test.startTest();
        logger.logMessage('Debug', 'COM_LoggerTest','testLogging', 'sampleMessage', null, null, null);
        Test.stopTest();

        List<Application_Log__c> existingLogs = [
            SELECT Source__c, Debug_Level__c, Source_Function__c, Message__c
            FROM Application_Log__c
        ];

        System.assertEquals(1, existingLogs.size());
        System.assertEquals('Debug', existingLogs[0].Debug_Level__c);
        System.assertEquals('COM_LoggerTest', existingLogs[0].Source__c);
        System.assertEquals('testLogging', existingLogs[0].Source_Function__c);
        System.assertEquals('sampleMessage', existingLogs[0].Message__c);
    }

    @IsTest
    private static void testLoggingWithReferences() {
        insertSettingForLogger(true, true, true, 1);
        COM_Logger logger = new COM_Logger();
        
        Test.startTest();
        logger.logMessage('Debug', 'COM_LoggerTest','testLogging', 'referenceId', 'referenceInfo', 'sampleMessage', null, null, null);
        Test.stopTest();

        List<Application_Log__c> existingLogs = [
            SELECT Source__c, Debug_Level__c, Source_Function__c, Message__c, Reference_Id__c, Reference_Info__c
            FROM Application_Log__c
        ];

        System.assertEquals(1, existingLogs.size());
        System.assertEquals('Debug', existingLogs[0].Debug_Level__c);
        System.assertEquals('COM_LoggerTest', existingLogs[0].Source__c);
        System.assertEquals('testLogging', existingLogs[0].Source_Function__c);
        System.assertEquals('sampleMessage', existingLogs[0].Message__c);
        System.assertEquals('referenceId', existingLogs[0].Reference_Id__c);
        System.assertEquals('referenceInfo', existingLogs[0].Reference_Info__c);
    }

    private static void insertSettingForLogger(Boolean debugFlag, Boolean errorFlag, Boolean infoFlag, Integer logPurgeDays) {
        System_Setting__c setting = new System_Setting__c(Debug__c = debugFlag, Error__c = errorFlag, Info__c = infoFlag, Log_Purge_Days__c = logPurgeDays);
        insert setting;
    }
}