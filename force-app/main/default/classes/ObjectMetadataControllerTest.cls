@isTest
public with sharing class ObjectMetadataControllerTest {
    
    @isTest static void getObjectNamesTest() { 
        Test.startTest();
        // code_block
            List<ObjectMetadataController.objectWrapper> objwrap = ObjectMetadataController.getObjectNames();
            System.assertNotEquals(null, objwrap.size());
        Test.stopTest();
    }   
}