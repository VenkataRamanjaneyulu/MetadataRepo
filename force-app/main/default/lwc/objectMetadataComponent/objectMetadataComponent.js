import { LightningElement,wire,api,track } from 'lwc';
import  getObjectNames from '@salesforce/apex/ObjectMetadataController.getObjectNames';

import objectChanged from '@salesforce/messageChannel/ObjectChanged__c';
// Import message service features.
import {publish,
        APPLICATION_SCOPE,
        MessageContext
      } from 'lightning/messageService';
import {exportCSVFile} from 'c/csvUtil';

const columns = [
    
    { 
        label: 'Object Name', 
        fieldName: 'LabelName',
        type:'text'
    },
    { 
        label: 'API Name', 
        fieldName: 'ApiName',
        type:'text'
    },
    { 
        label: 'Key Prefix', 
        fieldName: 'KeyPrefix',
        type:'text' 
    },
    {
        type: "button",
        fixedWidth: 150,
        typeAttributes: {
            label: 'View Fields',
            title: 'View Fields',
            name: 'viewFields',
            value: 'viewFields',
            variant: 'brand',
            class: 'scaled-down'
        }
    },
    
];

export default class ObjectMetadataComponent extends LightningElement { 

    options = [
        {
           value: 'all-objects',      
           label: 'All Objects', 
           description: 'To fetch all objects'
        },
        {
           value: 'standard-objects', 
           label: 'Standard Objects', 
           description: 'To fetch only standard objects'
        },
        {
           value: 'custom-objects',   
           label: 'Custom Objects', 
           description: 'To fetch custom objetcs __c'
        }
    ];
    columns = columns;
    headers = {
        LabelName:"LabelName",
        ApiName:"ApiName",
        KeyPrefix:"KeyPrefix"
    }

    objectTypeToFetch='custom-objects';
    searchKey='';
    isLoading = true;
    _count=0;
    _showExport = false;
    selectedObject='';
    totalNumberOfRows=0;
    

    allObjectsList=[];
    standardObjectList=[];
    customObjectList=[];
    otherObjects =[];
    rows;
    priorFilteredRows=[];

    
    @track filteredRows=[];
    @track error;

    get countOfObjects(){
        if(this.filteredRows.length>0){        
          return this.filteredRows.length;
        }else{         
            return this._count;
        }
    }
   
    @wire(getObjectNames)
    getObjects({data,error}){
        if(data){  
            console.log('data is ~~~~~~~',data);           
            this.rows = data; //for backup
            this.filterData(data);  
            this.filteredRows       = this.customObjectList; 
            this.priorFilteredRows  = this.customObjectList;
            this.totalNumberOfRows  = this.customObjectList.length;
            this._showExport = this.filteredRows.length>0?true:false;
            this.isLoading = false;
        }else if(error){   
            this.error = error.body.message;      
            console.error('error occured', error);
        }
    }

    // To pass scope, you must get a message context.
    @wire(MessageContext)
    messageContext; 

    filterData(dataFetched){
        Array.from(dataFetched).forEach( (item)=>{
            if(item.ApiName.includes('__c')){
                this.customObjectList.push(item);
            }else if(!(item.ApiName.includes('__'))){
                this.standardObjectList.push(item);
            }else{
               this.otherObjects.push(item); 
            }
            if(!(item.ApiName.includes('__x'))){
                this.allObjectsList.push(item);
            }
        });      
        return;
    }
  
    exportAsCsv(){
        console.log('export objects', this.filteredRows.length);
        exportCSVFile(this.headers, this.filteredRows, 'Objects-List');
    }
  
    handleChange(event) {
       this.objectTypeToFetch = event.detail.value;
       this.filteredRows=[];
       this.priorFilteredRows =[];
       this.searchKey= '';
       this.isLoading = true;
       /*for making asyncronous in order to show spinner for js operations*/
       setTimeout(() => {
            this.handleObjectChange();
       }, 0);  

    }

    handleObjectChange(){   
            if(this.objectTypeToFetch =='custom-objects' ){
                this.filteredRows  = this.customObjectList;                   
                this.totalNumberOfRows  = this.customObjectList.length;
            }
            else if(this.objectTypeToFetch =='all-objects'){    
                this.filteredRows      = this.allObjectsList;                    
                this.totalNumberOfRows = this.allObjectsList.length;  
                       
            }
            else if(this.objectTypeToFetch =='standard-objects' ){
                this.filteredRows = this.standardObjectList;            
                this.totalNumberOfRows = this.standardObjectList.length;       
            }
            this.priorFilteredRows  = this.filteredRows ;
            this._showExport = this.filteredRows.length>0?true:false;
            this.isLoading = false;

    }

    handleSearch(event){
       this.isLoading = true;
       this.searchKey = event.target.value;
       this.searchKey = this.searchKey.toLowerCase();
       setTimeout(() => {
            this.filterByNameOrApi();
        }, 0);
        this.isLoading = false; 
       
    }

    filterByNameOrApi(){
      const regex = new RegExp('(^' + this.searchKey + ')|(.' + this.searchKey + ')|(' + this.searchKey + '$)');
      if(this.searchKey.length > 2){
          this.filteredRows = this.filteredRows.filter(item => {
              if( regex.test(item.ApiName.toLowerCase()) || regex.test(item.LabelName.toLowerCase()) ){
                  return item;        
              }    
          });
          
          
      }
      else if(this.searchKey.length <= 2){
         this.filteredRows =  this.priorFilteredRows;    
      }
      this._showExport = this.filteredRows.length>0?true:false;
      return;
      
    }

    handleRowAction(event){
        const selectedRow = event.detail.row;
        const message = {
                            apiName : selectedRow.ApiName,
                            labelName: selectedRow.LabelName
                        };

        const lmsMessage = {
                            lmsdata :{
                                        value: message,
                                      }
                           }
        
        publish(this.messageContext, objectChanged, lmsMessage);      
    }

}