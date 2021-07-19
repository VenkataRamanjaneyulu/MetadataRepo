public with sharing class ObjectMetadataController {

    @AuraEnabled(cacheable=true)
    public static List<objectWrapper> getObjectNames(){
        List<objectWrapper> objectWrapperList = new List<objectWrapper>();
        List<String> supportedObjects = new List<String>();
        for(EntityDefinition ed: [SELECT DeveloperName FROM EntityDefinition WHERE 
                                    IsApexTriggerable = true AND IsQueryable=true
                                     ORDER BY DeveloperName]){
            if(!ed.DeveloperName.contains('ChangeEvent')){
                supportedObjects.add(ed.DeveloperName);
            }      
        }

        for ( Schema.SObjectType sobjtyp : Schema.getGlobalDescribe().values() ) {     
            Schema.DescribeSObjectResult objResult = sobjtyp.getDescribe();
                objectWrapper objWrap   = new objectWrapper();                   
                        objWrap.ApiName         = objResult.getName();
                        objWrap.LabelName       = objResult.getLabel();
                        objWrap.KeyPrefix       = objResult.getKeyPrefix(); 
                if(!objResult.isCustom()){
                    if(supportedObjects.contains(objResult.getName())){
                        objectWrapperList.add(objWrap); 
                    } 
                } else if(objResult.isCustom()){
                    objectWrapperList.add(objWrap); 
                }
                          
        }
        objectWrapperList.sort();
        return  objectWrapperList;              
    }

    public class ObjectWrapper implements Comparable{       
        @AuraEnabled public String ApiName  {get;set;}
        @AuraEnabled public String LabelName{get;set;}
        @AuraEnabled public String KeyPrefix{get;set;}
        //constructor
        objectWrapper(){
        }
   
        //For sorting wrapper list
        public Integer compareTo(Object compareTo) {
                objectWrapper compareToObj = (objectWrapper)compareTo;
                if (LabelName == compareToObj.LabelName) return 0;
                if (LabelName > compareToObj.LabelName) return 1;
                return -1;        
        }

    }

    public class FieldsWrapper implements Comparable{       
        @AuraEnabled public String apiName     {get;set;}
        @AuraEnabled public String labelName   {get;set;}
        @AuraEnabled public String dataType    {get;set;}
        @AuraEnabled public Boolean required   {get;set;}
        @AuraEnabled public Boolean createable {get;set;}
        
        //constructor
        FieldsWrapper(){
        }
   
        //For sorting wrapper list
        public Integer compareTo(Object compareTo) {
               FieldsWrapper compareToField = (FieldsWrapper)compareTo;
                if (labelName == compareToField.labelName) return 0;
                if (labelName > compareToField.labelName) return 1;
                return -1;        
        }

    }

    
    @AuraEnabled (cacheable=true)
    public static List<FieldsWrapper> getListOfFields(String objectApiName){
        Map<string, string> fieldList = new Map<string, string>();
        List<FieldsWrapper> fieldsWrapperList = new List<FieldsWrapper>();
        if(!String.isEmpty(objectApiName)){
           /* Map<String, String> mapField = new Map<String, String>();
            Map<string,SObjectField> lstFields = 
                Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();

            for(String str: lstFields.keySet()){
                mapField.put(str, lstFields.get(str).getDescribe().getLabel());                
            }
            System.debug(JSON.serializePretty(mapField));
            return JSON.serializePretty(mapField); */
            Map<String, Schema.SObjectField> fieldsMap = 
            Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();

            for (String fieldName: fieldsMap.keySet()) {
                    FieldsWrapper fwrap =new FieldsWrapper();
                    fwrap.apiName   = fieldsMap.get(fieldName).getDescribe().getName();
                    fwrap.labelName = fieldsMap.get(fieldName).getDescribe().getLabel();
                    fwrap.dataType  = fieldsMap.get(fieldName).getDescribe().getType().name().toLowerCase().capitalize();//
                    fwrap.required   = !fieldsMap.get(fieldName).getDescribe().isNillable();
                    fwrap.createable = fieldsMap.get(fieldName).getDescribe().isCreateable();
                    fieldsWrapperList.add(fwrap);
            }
        }
        fieldsWrapperList.sort();
        return fieldsWrapperList;
    } 

    @AuraEnabled (cacheable=true)
    public static List<SObject> retreieveRecords(String objectName, 
                                                 String fieldApiNames)
    {
        String strQuery = 'SELECT ' + String.escapeSingleQuotes(fieldApiNames) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName);

        //SELECT Id, Name, Type, LastViewedDate, Profile.Name FROM RecentlyViewed 
        //WHERE Type ='Account' ORDER BY LastViewedDate DESC 
        return database.query(strQuery);
    }

}