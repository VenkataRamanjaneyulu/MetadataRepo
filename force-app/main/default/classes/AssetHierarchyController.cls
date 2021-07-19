public with sharing class AssetHierarchyController {
    
    @AuraEnabled(cacheable=true)
    public static List<AssetWrapper> getAssets(String accountId){
        Map<ID, Asset> topAssetsMap;
        if(accountId == null){
            topAssetsMap = new Map<ID, Asset>( [ SELECT ID,AccountId,AssetLevel,
                                Name,ParentId,Price,Product2Id,ProductCode 
                                FROM ASSET where 
                                ParentId ='']);
                                system.debug('Inside null accountId');
        }else{
            topAssetsMap = new Map<ID, Asset>( [ SELECT ID,AccountId,AssetLevel,
                                Name,ParentId,Price,Product2Id,ProductCode 
                                FROM ASSET where 
                                ParentId ='' AND AccountId=:accountId]);
        }
        
        
        List<Asset> allAssets = assetUtils.getChildAssets(topAssetsMap); //p1,c1p1,c1p1g1
    //getChildAssets(Id parentId, List<Asset> allAssets)

        List<AssetWrapper> assetWrapperList = new List<AssetWrapper>();
        for(Asset aset: topAssetsMap.values()) {
            assetWrapperList.add(new AssetWrapper (aset.Id, aset.accountId,aset.parentId,
            aset.Product2Id, aset.Name,aset.AssetLevel, AssetUtils.getChildAssets(aset.Id, allAssets).size()>0 ?AssetUtils.getChildAssets(aset.Id, allAssets):null ));
        }
        System.debug('Serialized list is~~~~~~~'+''+JSON.serialize(assetWrapperList, true));
        return assetWrapperList;
        //return JSON.serialize(assetWrapperList);

    }

}