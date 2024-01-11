@isTest
private class StringManager6Test {
   
    @isTest
    static void testGetDoubleStringSuccess(){
        String testString = 'test';
        System.assertEquals('test test', StringManager6.getDoubleSting(testString));
    }

    static void testGetDoubleStringNull(){
        System.assertEquals('', StringManager6.getDoubleSting(null));
    }
}