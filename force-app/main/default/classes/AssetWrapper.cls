public with sharing class AssetWrapper implements Comparable {
    
    @AuraEnabled public Id Id {get;set;}
    @AuraEnabled public Id AccountId {get;set;}
    @AuraEnabled public Id ParentId {get;set;}
    @AuraEnabled public Id Product2Id {get;set;}
    @AuraEnabled public String Name {get;set;}
    @AuraEnabled public Integer AssetLevel {get;set;}
    @AuraEnabled public List<AssetWrapper> items {get;set;}

    //constructor
    public AssetWrapper(Id Id,Id accountId,Id parentId,
                        Id product2Id , String name, 
                        Integer assetLevel, List<AssetWrapper> items)
    {
        this.Id =Id;
        this.AccountId =accountId;
        this.ParentId = parentId;
        this.Product2Id = product2Id;
        this.Name = name;
        this.AssetLevel = assetLevel;
        this.items = items;
    }

    //no arg constructor
    public AssetWrapper(){}

    //for sorting
    public Integer compareTo(Object objToCompare){
        return Name.compareTo(((AssetWrapper)objToCompare).Name);
    }
}