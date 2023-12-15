@isTest
private class StringManagerTest {
   
    @isTest
    static void testGetDoubleStringSuccess(){
        String testString = 'test';
        System.assertEquals('test test', StringManager.getDoubleSting(testString));
    }

    static void testGetDoubleStringNull(){
        System.assertEquals('', StringManager.getDoubleSting(null));
    }
}