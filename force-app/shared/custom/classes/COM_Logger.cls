public without sharing class COM_Logger {

    public final static String SIMPLIFIED_DESKTOP_REST_ENDPOINT_BASE = 'callout:SimplifiedDesktopBaseUrl';
    public final static String SIMPLIFIED_DESKTOP_REST_ENDPOINT_CREATE_LOG = '/services/data/v41.0/sobjects/Application_Log__c/';
    public final static String HEADER_ACCEPT = 'Accept';
    public final static String HEADER_CONTENT_TYPE = 'Content-Type';
    public final static String HEADER_VALUE_FORMAT_JSON = 'application/json;';
    public final static String HEADER_VALUE_METHOD = 'POST';

    public enum LogMode {MODE_DML, MODE_REST}

    private LogMode loggerMode;

    public COM_Logger() {
        this(LogMode.MODE_DML);
    }

    public COM_Logger(LogMode mode) {
        this.loggerMode = mode;
    }

    public void logMessage(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, long timeTaken) {

        COM_ApplicationLogWrapper msg = new COM_ApplicationLogWrapper();

        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = null;
        msg.referenceInfo = '';
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage(msg);
    }

    public void logMessage(String logLevel, String sourceClass, String sourceFunction, String referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, long timeTaken) {

        COM_ApplicationLogWrapper msg = new COM_ApplicationLogWrapper();

        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = referenceId;
        msg.referenceInfo = referenceInfo;
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage(msg);
    }

    public void logMessage(COM_ApplicationLogWrapper appLog) {

        List<COM_ApplicationLogWrapper> appLogs = new List<COM_ApplicationLogWrapper>();
        appLogs.add (appLog);
        logMessage (appLogs);
    }

    public void logMessage(List<COM_ApplicationLogWrapper> appLogs) {

        List<Application_Log__c> insertAppLogs = new List<Application_Log__c>();

        for (COM_ApplicationLogWrapper appLog : appLogs) {

            Application_Log__c log = new Application_Log__c();

            log.Source__c = appLog.source;
            log.Source_Function__c = appLog.sourceFunction;
            log.Reference_Id__c = appLog.referenceId;
            log.Reference_Info__c = appLog.referenceInfo;
            log.Message__c = appLog.logMessage;
            log.Integration_Payload__c = appLog.payload;

            if (appLog.ex != null) {
                log.Stack_Trace__c = appLog.ex.getStackTraceString();
                log.Message__c = applog.ex.getMessage();
            }

            log.Debug_Level__c = appLog.debugLevel;
            log.Log_Code__c = appLog.logCode;
            log.Timer__c = appLog.timer;

            if (isDebugLevelEnabled(appLog.debugLevel)) {
                if(loggerMode == LogMode.MODE_DML){
                    insertAppLogs.add(log);
                }
                if(loggerMode == LogMode.MODE_REST){
                    logMessageByRest(log);
                }
            }
        }

        if (insertAppLogs.size() != 0) {
            insert insertAppLogs;
        }
    }

    private void logMessageByRest(Application_Log__c log){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SIMPLIFIED_DESKTOP_REST_ENDPOINT_BASE + SIMPLIFIED_DESKTOP_REST_ENDPOINT_CREATE_LOG);
        request.setHeader(HEADER_CONTENT_TYPE, HEADER_VALUE_FORMAT_JSON);
        request.setHeader(HEADER_ACCEPT, HEADER_VALUE_FORMAT_JSON);
        request.setMethod(HEADER_VALUE_METHOD);
        request.setBody(JSON.serialize(log));

        Http http = new Http();
        HttpResponse response = http.send(request);
    }

    private Boolean isDebugLevelEnabled(String debugLevel) {
        Set<String> settings = Schema.SObjectType.System_Setting__c.fields.getMap().keySet();
        return settings.contains(debugLevel.toLowerCase() + '__c')
                && System_Setting__c.getInstance().get(debugLevel + '__c') != null
                && Boolean.valueOf(System_Setting__c.getInstance().get(debugLevel + '__c'));
    }
}