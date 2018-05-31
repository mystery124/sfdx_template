public with sharing class IS_IdentityAPIConfigurationAccessor {
    private final static String META_CONFIG_OBJECT_NAME = 'Client_IdentityAPI_Integration__mdt';
    private final static String META_CONFIG_DEVELOPER_NAME = 'IdentityAPI';
    private static Map<String, String> valueByType;

    public static String getConfig(String key) {
        if (valueByType == null) {
            valueByType = new COM_MetaConfigurationAccessor(META_CONFIG_OBJECT_NAME, META_CONFIG_DEVELOPER_NAME).buildConfigMap();
        }
        return valueByType.get(key);
    }
}