import { LightningElement,wire } from 'lwc';
import getAccounts from '@salesforce/apex/DynamicTreeStructure.getAccounts';

export default class DynamicTreeStructure extends LightningElement { 
   
   @wire(getAccounts) 
   accounts;

   
}