public class SearchAccount {
    
    @AuraEnabled(cacheable=true)
    public static Contact createContact(String title1, String salutation1, String firstName,String lastName,
                                              String accountId,  String email1, Date birthday){
        Contact con = new Contact();
        SearchAccount acc1= new SearchAccount();
        //String accessToken=acc1.ReturnAccessToken(acc1);
       // System.debug(accessToken+'###MDK');
        //if(accessToken!=null){
            String endPoint='callout:CalloutNamedCred/services/apexrest/api/contact'; 
            ContactWrapper conWrapper = new ContactWrapper();
                conWrapper.accId = accountId;
                conWrapper.fName = firstName;
                conWrapper.lName = lastName;
                conWrapper.bDay = birthday;
                conWrapper.email = email1;
                conWrapper.title = title1;
                conWrapper.salutation = salutation1;
           
           
            ContactWrapperReq conWrapReq = new ContactWrapperReq();
                conWrapReq.conWrapper = conWrapper;
                system.debug('###'+json.serialize(conWrapReq));
            String jsonstr=json.serialize(conWrapReq);

            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            //req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(jsonstr);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);

            HttpResponse res2=h2.send(req2);
            System.debug('res2###'+res2);
            System.debug(res2.getBody()+'###Michael###');

            ContactWrapperResponse deresp= (ContactWrapperResponse)System.JSON.deserialize(res2.getBody(),ContactWrapperResponse.class);
            System.debug('### Deserialized Response ###'+deresp);
            system.debug('deresp.accountList#'+deresp.contact);
            con = deresp.contact;
        //}
        return con;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String keySearch){
        List<Account> accList = new List<account>();
        SearchAccount acc1= new SearchAccount();
        String endPoint='callout:CalloutNamedCred/services/apexrest/api/accounts'; 
            AccountWrapper accWrapper = new AccountWrapper();
                accWrapper.Name=keySearch;
            AccountWrapperReq accWrapReq = new AccountWrapperReq();
                accWrapReq.accWrapper = accWrapper;
                system.debug('###'+json.serialize(accWrapReq));
                String jsonstr=json.serialize(accWrapReq);

            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
               // req2.setHeader('Authorization','Bearer ' + accessToken);
                req2.setHeader('Content-Type','application/json');
                req2.setHeader('accept','application/json');
                req2.setBody(jsonstr);
                req2.setMethod('POST');
                req2.setEndpoint(endPoint);

            HttpResponse res2=h2.send(req2);
            System.debug('res2###'+res2);
            
            System.debug(res2.getBody()+'###Michael###');

            AccountWrapperResponse deresp= (AccountWrapperResponse)System.JSON.deserialize(res2.getBody(),AccountWrapperResponse.class);
            System.debug('### Deserialized Response ###'+deresp);
            system.debug('deresp.accountList#'+deresp.acctList);
            accList = deresp.acctList;
        
        return accList;
    }

    public class deserializeResponse {
        public String id;
        public String access_token;
    }
   
    public class AccountWrapperReq {
        public AccountWrapper accWrapper;
    }
    public class AccountWrapper{
        public string Name;
    }
    public class ContactWrapperReq {
        public ContactWrapper conWrapper;
    }
    public class ContactWrapper{
        public String accId;
        public String fName;
        public String lName;
        public Date bDay;
        public String email;
        public String title;
        public String salutation;
    }

    public class AccountWrapperResponse {
        public List<Account> acctList = new List<Account>();
        public String status;
        public String message;
    }
  
    public class ContactWrapperResponse {
        public Contact contact;
        public String status;
        public String message;
    }
}