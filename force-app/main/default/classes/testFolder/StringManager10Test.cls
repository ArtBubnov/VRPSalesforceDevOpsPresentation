@isTest
private class StringManager10Test {
   
    @isTest
    static void testGetDoubleStringSuccess(){
        String testString = 'test';
        System.assertEquals('test test', StringManager10.getDoubleSting(testString));
    }

    static void testGetDoubleStringNull(){
        System.assertEquals('', StringManager10.getDoubleSting(null));
    }
}