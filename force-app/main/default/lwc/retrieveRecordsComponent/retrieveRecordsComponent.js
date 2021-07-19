import { LightningElement,api,wire,track } from 'lwc';
import  getRecords from '@salesforce/apex/ObjectMetadataController.retreieveRecords';

export default class RetrieveRecordsComponent extends LightningElement {
   @api objectApiName ='';
   @api fieldApiNames ='' ; 
   @api numberOfRecords =0;
   @api columns=[];

   isLoading= true;
   areRecordsVisible= false; 
   _showExport =false;
   isLoading=false;
   showRecords;

   @track data=[];
   @track error;

   /*
   @wire(getRecords,{objectName:'$objectApiName',
                     fieldApiNames:'$fieldApiNames',
                     numberOfRecords:'$numberOfRecords'
                    })
   wiredObjects({ error, data }) {
        if (data) {
            console.log('data ',data); 
            this.data= JSON.parse(JSON.stringify(data));    
            if(data.length >=0){
                this.showRecords =true;
            }     
            //this.data = data;  
            this.areRecordsVisible =true;
            this.isLoading = false;          
            this.error = undefined;
        } else if (error) {
            console.log('Error occured in fetching records==>',error);
            this.error = error.body.message;
            this.data = undefined;
            this.isLoading = false;
        }
   }
*/
   
   @api 
   handleGetRecords(){
       console.log('get records called');
       console.log('objectName is :::',this.objectApiName);
       console.log('fieldApiNames is :::',this.fieldApiNames);

       if( (this.objectApiName) && (this.fieldApiNames)){
                getRecords({objectName: this.objectApiName,
                            fieldApiNames: this.fieldApiNames
                })
                .then(result =>{
                    this.data = result;
                    if(this.data.length>=1){
                            this.showRecords  =true;
                    }
                    console.log('data from records comp is===>',this.data);
                })
                .catch(error =>{
                    this.error = error;
                    console.error('An error occured in recordsComponent==>',this.error);
                })
        }
    }

}