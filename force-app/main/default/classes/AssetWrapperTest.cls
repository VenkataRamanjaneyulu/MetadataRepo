@isTest
public with sharing class AssetWrapperTest {

    @testSetup static void setup() {
        Account acc;    
        try{
            acc = new Account();
            acc.Name='Test Account';
        	insert acc;
        }catch(Exception e){
            System.debug('An exception occured!'+''+e.getMessage());
        }
        
        List<Asset> asetList = new List<asset>();
        for(Integer i=0; i<3;i++){
               Asset aset = new Asset();	
                aset.Name = 'Test Asset'+i;
                aset.IsCompetitorProduct = false;
                aset.IsInternal = false;
                aset.AccountId = acc.Id;
                asetList.add(aset);
            }
        try{       
        	insert asetList;
        }catch(Exception e){
            System.debug('An exception occured!'+''+e.getMessage());
        }     
    }
    
    
    @isTest
    public static void testAssetWrapperConstructor(){
        Account acc= [Select id,name from Account limit 1];    
        System.debug('Account Id is====>'+''+acc.Id);
        Asset aset = [Select id,AccountId,ParentId,Product2Id,Name,AssetLevel from Asset limit 1]; 
		System.debug('Asset Id is : ----->'+''+aset.Id);
        if(aset.Id!=null){
            AssetWrapper awrap = new  AssetWrapper (aset.Id,aset.AccountId,aset.ParentId,
                    aset.Product2Id,aset.Name,aset.AssetLevel,null);
            System.assertNotEquals(null, awrap);	
        }       
    }
    
    @isTest
    public static void testAssetWrapperNoArgConstructor(){
    	AssetWrapper awrap = new  AssetWrapper();
         System.assertEquals(null, awrap.name);
    }

	@isTest
    public static void testAssetWrapperComparator(){
        List<AssetWrapper> assetWrapperList = new List<AssetWrapper>();
        for(Asset aset: [Select id,AccountId,ParentId,Product2Id,Name,AssetLevel from Asset]){
            AssetWrapper awrap = new  AssetWrapper();
            awrap.Id= aset.Id;
            awrap.AccountId= aset.AccountId;
            awrap.ParentId =aset.ParentId;
            awrap.Product2Id= aset.Product2Id;
            awrap.Name= aset.Name;
            awrap.AssetLevel= aset.AssetLevel;
            awrap.items= null;
            assetWrapperList.add(awrap);
        }
        assetWrapperList.sort();
        system.assertEquals(assetWrapperList[0].Name, 'Test Asset0');
    }
}