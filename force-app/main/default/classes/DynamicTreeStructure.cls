public with sharing class DynamicTreeStructure {
    public DynamicTreeStructure() {}

    private static Map<Id, TreeStructure> result;
    private static Map<Id, Id> childIdMap;

    /**
    Static Method to be fed in @wire for LWC
    */
    @AuraEnabled(cacheable=true)
    public static List<TreeStructure> getAccounts(){
        result = new Map<Id, TreeStructure>();
        childIdMap = new Map<Id, Id>();
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE ParentId = null]);
        if(!accMap.isEmpty()){
            startFetchingAccountDetails(accMap);
        }
        System.debug(JSON.serialize(result));
        return result.values();
    }

    /**
    * Recursion method to get all levels of accounts and their related records
    */
    private static List<TreeStructure> startFetchingAccountDetails(Map<Id, Account> accMap){
        Map<Id, TreeStructure> parentStructure = gatherAllAccountInformation(accMap);

        //attach the first level to actual result and rest will auotmatically link
        //due to pass by reference way
        if(result == null || result.isEmpty()){
            result.putAll(parentStructure);
        }
        Map<Id, Account> childMap = new Map<Id, Account>([SELECT Id, Name, ParentId FROM Account WHERE ParentId =: accMap.keySet()]);
        if(childMap != null && !childMap.isEmpty() && childMap.size() > 0){
            Map<Id, Id> accChildIdMap = new Map<Id, Id>();
            for(Id childAccountId : childMap.keySet()){
                Account child = childMap.get(childAccountId);
                childIdMap.put(child.Id, child.ParentId);
            }

            //run this method recursively to get all child levels.
            List<TreeStructure> childStructure = startFetchingAccountDetails(childMap);
            for(TreeStructure child : childStructure){
                TreeStructure parent = parentStructure.get(childIdMap.get(child.name));
                parent.items.add(child);
            }
        }
        return parentStructure.values();
    }

    /**
    * Method to gather all information for all accounts recieved
    */
    private static Map<Id, TreeStructure> gatherAllAccountInformation( Map<Id, Account> accMap){
        Map<Id, TreeStructure> result = new Map<Id, TreeStructure>();

        Map<Id, List<Contact>> accConMap = new  Map<Id, List<Contact>>();
        Map<Id, List<Opportunity>> accOppCMap = new Map<Id, List<Opportunity>>();
        Map<Id, List<Case>> conCaseCMap = new Map<Id, List<Case>>();

        //gather all contacts
        for(Contact con : [SELECT Id, Name, AccountId FROM Contact WHERE AccountId =: accMap.keySet()]){
            if(!accConMap.containsKey(con.AccountId)){
                accConMap.put(con.AccountId, new List<Contact>());
            }
             accConMap.get(con.AccountId).add(con);
        }

        //gather all opportunities
        for(Opportunity opp : [SELECT Id, Name, AccountId FROM Opportunity WHERE AccountId =: accMap.keySet()]){
            if(!accOppCMap.containsKey(opp.AccountId)){
                accOppCMap.put(opp.AccountId, new List<Opportunity>());
            }
             accOppCMap.get(opp.AccountId).add(opp);
        }

        //gather all cases
        for(Case cas : [SELECT Id, CaseNumber, ContactId FROM Case WHERE ContactId =: accConMap.keySet()]){
            if(!conCaseCMap.containsKey(cas.ContactId)){
                conCaseCMap.put(cas.ContactId, new List<Case>());
            }
            conCaseCMap.get(cas.ContactId).add(cas);
        }

        for(Id accountId : accMap.keySet()){
            Account acc = accMap.get(accountId);
            TreeStructure accStructure = new TreeStructure(acc.name, accountId, false, null);

            //add all contacts if present
            if(accConMap.containsKey(accountId)){
                TreeStructure conStructure = new TreeStructure('Contacts', 'Contacts', false, null);
                for(Contact con :  accConMap.get(accountId)){
                    conStructure.items.add( new TreeStructure(con.Name, con.Id, false, null));
                    if(conCaseCMap.containsKey(con.Id)){
                        TreeStructure caseStructure = new TreeStructure('Cases', 'Cases', false, null);
                        for(Case cas : conCaseCMap.get(con.Id)){
                            caseStructure.items.add( new TreeStructure(cas.CaseNumber, cas.Id, false, null));
                        }
                        conStructure.items.add(caseStructure);
                    }
                }
                accStructure.items.add(conStructure);
            }

            //add all opportunities if present
            if(accOppCMap.containsKey(accountId)){
                TreeStructure oppStructure = new TreeStructure('Opportunities', 'Opportunities', false, null);
                for(Opportunity opp :  accOppCMap.get(accountId)){
                    oppStructure.items.add( new TreeStructure(opp.Name, opp.Id, false, null));
                }
                accStructure.items.add(oppStructure);
            }

            result.put(accountId, accStructure);
        }
        return result;
    }
}