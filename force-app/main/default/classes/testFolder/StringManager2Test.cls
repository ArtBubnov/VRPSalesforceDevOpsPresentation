@isTest
private class StringManager2Test {
   
    @isTest
    static void testGetDoubleStringSuccess(){
        String testString = 'test';
        System.assertEquals('test test', StringManager2.getDoubleSting(testString));
    }

    static void testGetDoubleStringNull(){
        System.assertEquals('', StringManager2.getDoubleSting(null));
    }
}