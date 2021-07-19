import { LightningElement,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class TestUIIssue extends LightningElement {

   objectApiName = 'Account';

   @wire(getObjectInfo, { objectApiName: '$objectApiName' })
   objectInfo({data,error}){
         if(data){
            console.log('Data is ====>',data);         
         }
         else if(error){         
            console.error('error occured',error);
         }
    }

}