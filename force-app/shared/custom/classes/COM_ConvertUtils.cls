public class COM_ConvertUtils {

    public static String mapToQueryString(Map<String, String> params) {
        String body = '';
        for (String key : params.keySet()) {
            body += key + '=' + params.get(key) + '&';
        }
        return body.removeEnd('&');
    }
}