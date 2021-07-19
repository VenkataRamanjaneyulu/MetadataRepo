import { LightningElement ,track} from 'lwc';
import getAccounts from "@salesforce/apex/AccountFetchController.getAccounts";
import createContact from "@salesforce/apex/AccountFetchController.createContact";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountSearch extends LightningElement {

    searchKeyword;
    data=[];
    error;
    showContactCreate =false;
    showContactForm=false;
    dataNotFound=false;
    isLoading = false;
    columns =[
      { 
         label: 'Id', 
         fieldName: 'Id'
      },{ 
         label: 'Name', 
         fieldName: 'Name'
      },
    ];
    accountId='';
    @track contact={};
    

    handleKeyUp(evt) {
           this.searchKeyword = evt.target.value;  
           console.log('search key is ===>',this.searchKeyword);
           if(this.searchKeyword.length>=3){
              console.log('key is more than 3 letters');
              this.fetchAccounts();
           }
    }

    fetchAccounts(){
      this.isLoading = true;
      console.log('Inside fetch accounts',this.searchKeyword);
      getAccounts({
         searchKey : this.searchKeyword,
      })
      .then( response =>{
            this.data = response;
            console.log('Data for accounts is==>',this.data);
            this.error = undefined;
            if (this.data.length ==0) {
               this.dataNotFound = true;
               this.showContactCreate = false;
            }
            this.isLoading=false;
            
      })
      .catch( error =>{
            this.error = error;
            this.accounts= undefined;
            this.showContactCreate= false;
            this.isLoading=false;
            console.error('error for accounts is==>',error);
      })
    }

    handleRowSelection(event){
      const selectedRows = event.detail.selectedRows;
      console.log('Selected accounts are==>',selectedRows.length);
      if(selectedRows.length>1){ 
            this.showContactCreate = false;  
            const event = new ShowToastEvent({
                title: 'Warning!',
                message: 'Please select only one record in order to see create contact button.',
                variant: 'warning',
                mode:'pester'
            });
            this.dispatchEvent(event);
      }else if(selectedRows.length==1){
         this.showContactCreate= true;
         console.log('Account id is:::',selectedRows[0].Id);
         this.accountId = selectedRows[0].Id;
      }else{
         this.showContactCreate= false;
      }
      
    }

    handleInputChange(event){
      if(event.target.name == "lastName" ){
         this.contact.LastName = event.target.value; 
      }else if(event.target.name == "firstName" ){
         this.contact.FirstName = event.target.value; 
      }
    }

    handleContactCreate(){
         this.showContactForm = true;
         console.log('Create contact clicked');
    }

    handleCancelClick(){
       console.log('Cancel clickked');
      this.contact={};
      this.showContactForm = false;
    }

    handleSaveClick(){  
      console.log('Save clickked'); 
      this.contact.AccountId =  this.accountId;
      this.callCreateContact();
      this.showContactForm = false; 
    }

    callCreateContact(){
      console.log('Contact is ====>', this.contact);
      createContact({
         contact : this.contact,
      })
      .then( result => {
         console.log('result is==>',result);
         const event = new ShowToastEvent({
            title: 'Success!',
            message: `Contact created Succesfully! Id is: ${result}`,
            variant: 'success',
            mode:'pester'
        });
        this.dispatchEvent(event);
      })
      .catch(error =>{
         console.error('error is==>',error);
      })
    }
}