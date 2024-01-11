public with sharing class StringManager7 {
    public static String getDoubleSting(String stringVal){
        String result = '';
        if(stringVal != null && stringVal != ''){
            result = stringVal + ' ' + stringVal;
        }

        return result;
    }
}