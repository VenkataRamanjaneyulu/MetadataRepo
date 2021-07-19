public with sharing class AccountFetchController {
    public AccountFetchController() {}

    @AuraEnabled
    public static List<sObject> getAccounts(String searchKey){
        List<Account> accList = new List<Account>();
        //string tempInput = '%' + searchKey + '%';
        try {
            accList = fetchAccountsFromOtherOrg(searchKey);
            //accList = [Select id,name from Account where Name like :tempInput];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return accList;
    }

    @AuraEnabled
    public static string createContact(Contact contact){
        Contact con= new Contact();
        try {
            if(contact != null){
                con.LastName = contact.lastName;
                con.FirstName = contact.firstName;
                con.AccountId = contact.accountId;
                insert con;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('Contact is==>'+''+contact);
        return con.Id;
    }

 
    public static List<Account> fetchAccountsFromOtherOrg(String searchKey){
        List<Account> accList = new List<Account>();
        AccountWrapper accWrapper = new AccountWrapper();
            accWrapper.Name= searchKey;
        AccountWrapperReq accWrapReq = new AccountWrapperReq();
            accWrapReq.accWrapper = accWrapper;
        String jsonstr = json.serialize(accWrapReq);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
                    req.setEndpoint('callout:CalloutNamedCred/services/apexrest/api/accounts');
                    req.setMethod('POST');
                    req.setBody(jsonstr);
         
        HTTPResponse resp = http.send(req);
        System.debug('Response from another org is ~~~~~'+''+resp);
        AccountWrapperResponse deresp;
        if (resp.getStatusCode() == 200) {
             deresp= (AccountWrapperResponse)System.JSON.deserialize(resp.getBody(),AccountWrapperResponse.class);
             accList = deresp.acctList;
        }
        
        return accList;
    }

    public class AccountWrapperResponse {
        public List<Account> acctList = new List<Account>();
        public String status;
        public String message;
    }

    public class AccountWrapperReq {
        public AccountWrapper accWrapper;
    }
    public class AccountWrapper{
        public string Name;
    }
}