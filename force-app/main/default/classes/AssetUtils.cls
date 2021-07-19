public with sharing class AssetUtils {
    
    public static boolean isFirstTime = true;
    public static List<Asset> assets = new List<Asset>();//P1,C1P1,C2P1

    public static List<Asset> getChildAssets(Map<Id,Asset> topAssets){
        if (isFirstTime){
            isFirstTime = false;
            assets.addAll(topAssets.values());
        }

        Set<Id> assetIds = topAssets.keyset();
        Map<Id,Asset> childMap = new Map<Id,Asset>([SELECT ID,AccountId,AssetLevel,
                                Name,ParentId,Price,Product2Id,
                                ProductCode FROM ASSET where 
                                ParentId =: assetIds ]);

        assets.addAll(childMap.values());

        if (!childMap.isEmpty()){
            // recursively call the same method to fetch all the child assets until no further
            // child assets are returned back
            getChildAssets(childMap);
        }
        return assets;
    }

    public static List<AssetWrapper> getChildAssets(Id parentId, List<Asset> allAssets){

        List<AssetWrapper> childAssets = new List<AssetWrapper>();
        //parentId p1
        //p1,c1p1,c1p1g1
        for(Asset aset: allAssets){
            if(parentId == aset.ParentId) {
                // recursively call the same method to form a n-th level deep hierarchy
                childAssets.add(new AssetWrapper(aset.Id, aset.accountId,aset.parentId,
                                    aset.Product2Id, aset.Name,aset.AssetLevel, getChildAssets(aset.Id, allAssets)));
                // sort alphabetically
                childAssets.sort();
            }
        }
        return childAssets;
    }

}