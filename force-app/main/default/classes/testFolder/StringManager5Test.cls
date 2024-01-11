@isTest
private class StringManager5Test {
   
    @isTest
    static void testGetDoubleStringSuccess(){
        String testString = 'test';
        System.assertEquals('test test', StringManager5.getDoubleSting(testString));
    }

    static void testGetDoubleStringNull(){
        System.assertEquals('', StringManager5.getDoubleSting(null));
    }
}