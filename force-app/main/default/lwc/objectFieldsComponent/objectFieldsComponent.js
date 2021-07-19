import { LightningElement,api,wire,track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import  getListOfFields from '@salesforce/apex/ObjectMetadataController.getListOfFields';

import objectChanged from '@salesforce/messageChannel/ObjectChanged__c';
import {APPLICATION_SCOPE, MessageContext,subscribe, unsubscribe} 
     from 'lightning/messageService';

import {exportCSVFile} from 'c/csvUtil';
import {loadStyle} from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/datatableStyle'

const columns = [  
   { 
       label: 'Field Label Name', 
       fieldName: 'labelName',
       type:'text',
       hideDefaultActions: false,
       cellAttributes: { 
           class: { 
                    fieldName: 'requiredColor' 
                  }
       }
   },
   { 
       label: 'Field Api Name', 
       fieldName: 'apiName',
       type:'text',
       hideDefaultActions: false,
       cellAttributes: { class: { fieldName: 'requiredColor' }}
   },
   { 
       label: 'Data Type', 
       fieldName: 'dataType',
       type:'text',
       hideDefaultActions: true,
       cellAttributes: { class: { fieldName: 'requiredColor' }}
   },
   
];

export default class ObjectFieldsComponent extends LightningElement {
    columns = columns;
    headers = {
                label:"Field Label Name",
                apiName:"Field Api Name",
                dataType:"Data Type",
                required:"Is Required?"
             }

    searchKey='';
    choosenDataType='All';
    fieldDataTypes=['All'] ;
    passedMessage;
    _count=0;
    _showExport = false;
    isLoading = true;
    isCssLoaded = false;
    selectedFieldsValue ; 
    objectNametoFetch; 
    fieldsToFetch;
    rows;
    priorFilteredRows;
    error;
    items=[];
    maxNumOfRecords;
    objectApiName;
    objectLabelName;
    objectApiNameToRecords;

    @track filteredRows=[];
    @track options = []; 

    get objectName(){
    return `Fields of Object : `+ this.objectLabelName;
    }

    get countOfFields(){
        if(this.filteredRows){        
        return this.filteredRows.length;
        }else{         
            return this._count;
        }
    }

    /*
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({data,error}){
         if(data){
            this.filteredRows=[];
            this.rows  = Object.values(data.fields);
            console.log('ui api fields are==>',this.rows);
            this.isLoading = true;
            setTimeout(() => {
                this.processAsync();
                }, 0);   
            this.error=undefined;           
         }
         else if(error){
             if(error.body.message.includes('not supported')){
                 this.error = 'Unfortunately this object is not supported for fetching fields';
             }else{
                this.error = error.body.message; 
             }       
            this.filteredRows=undefined;
            this.isLoading = false;              
            console.error('error occured',error.body.message);
         }
    }
 */

    
    @wire(getListOfFields, { objectApiName: '$objectApiName' })
    objectInfo2({data,error}){
         if(data){
                console.log('field data is ===>',data); 
                this.filteredRows=[];
                this.rows = data;
                this.isLoading = true;
                setTimeout(() => {
                    this.processAsync();
                    }, 0);   
                this.error=undefined;       
         }
         else if(error){            
                if(error.body.message.includes('not supported')){
                    this.error = 'Unfortunately this object is not supported for fetching fields';
                }else{
                this.error = error.body.message; 
                }       
                this.filteredRows=undefined;
                this.isLoading = false;              
                console.error('error occured',error.body.message);
         }
    }
    
    

   // To pass scope, you must get a message context.
    @wire(MessageContext)
    messageContext; 

    connectedCallback(){
       this.subscribeHandler();
    }

    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
            console.log("CSS Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }

    subscribeHandler(){
      this.subscription = subscribe(this.messageContext,objectChanged, 
        (lmsMessage) => {
          this.messageHandler(lmsMessage)
        },
        {
            scope:APPLICATION_SCOPE
        });
    }
   
    messageHandler(passedData){
        this.passedMessage = passedData.lmsdata.value; 
        this.objectApiName = this.passedMessage.apiName;
        this.objectLabelName= this.passedMessage.labelName;
        this.objectApiNameToRecords = this.passedMessage.apiName;
        this.selectedFieldsValue = '';

    }

    processAsync(){
        this.filteredRows='';

        this.cssGenerator(this.rows); 
        this._showExport = this.filteredRows.length>0?true:false;
        this.options ='';
        this.optionsGenerator();  
        this.isLoading = false; 
        this.error=undefined; 
    }
    optionsGenerator(){
        const dataTypes = [... new Set( this.filteredRows.map( item => item.dataType))] ; 
            const dataTypesWithAll = this.fieldDataTypes.concat(Array.from(dataTypes));   
            dataTypesWithAll.forEach((item)=>{
                this.options = [...this.options ,
                    {
                    value: item, 
                    label: item,
                    description:`To show only ${item} fields`,
                   }
                ]; 
            })

    }

    cssGenerator(data){  
        this.rows = data.map(item=>{
            const bgColor = (item.required && item.createable)? "required-field":"normal-field";
            return {...item,
                "requiredColor": bgColor ,
            }
        });        
        this.filteredRows = this.rows;
        this.priorFilteredRows = this.rows;
    }

    exportData(){
        exportCSVFile(this.headers, this.filteredRows, `${this.objectLabelName}-Feilds`);
    }
  
    search(event){
      this.isLoading = true;  
      this.searchKey = event.target.value;
      this.searchKey = this.searchKey.toLowerCase();
      const regex = new RegExp('(^' + this.searchKey + ')|(.' + this.searchKey + ')|(' + this.searchKey + '$)');   
      if(this.searchKey.length > 2){
          this.filteredRows = this.rows.filter(item => {
              if( regex.test(item.apiName.toLowerCase()) || regex.test(item.label.toLowerCase()) ){
                  return item; 
              }
          
          });
      }
      else if(this.searchKey.length <= 2){
         this.filteredRows =  this.rows;
      }
      this.priorFilteredRows = this.filteredRows;
      this.options ='';
      this.optionsGenerator(); 
      this._showExport = this.filteredRows.length>0?true:false;
      this.isLoading = false;  
    }

    handleChange(event){
      this.choosenDataType = event.target.value;
      this.isLoading = true;       
      setTimeout(() => {
        this.handleFieldChange();
        }, 0);    
    }

    handleFieldChange(){
      this.filteredRows = this.priorFilteredRows.filter( item => {
          if(this.choosenDataType =='All'){
            return item;
          }
          else if(item.dataType == this.choosenDataType ){
              return item;
          }
      });
      this.options ='';
      this.optionsGenerator();
      this._showExport = this.filteredRows.length>0?true:false;
      this.isLoading = false;

    }

    handleRowAction(event){
        const selectedRows = event.detail.selectedRows;        
        this.selectedFieldsValue = '';  
        selectedRows.map( element=>{
            if(this.selectedFieldsValue !=='' ){        
                    this.selectedFieldsValue = this.selectedFieldsValue + ',' + element.apiName;    
            }
            else{
                this.selectedFieldsValue = element.apiName;
            }
        });
        
    }

    handleRetrieveRecords(){
        this.fieldsToFetch = this.selectedFieldsValue;
        this.objectNametoFetch = this.objectApiNameToRecords;
        this.maxNumOfRecords = 50;
        this.items='';

        let columnFields = this.selectedFieldsValue.split(',');
        columnFields.map( (element) => {
            let itemValue = element.charAt(0).toUpperCase()+ element.slice(1);
            this.items = [...this.items ,{label: itemValue, 
                                          fieldName: itemValue
                                         }
                        ];    
        });
        console.log('inside records fetch click',this.fieldsToFetch);
        this.template.querySelector('c-retrieve-records-component').handleGetRecords();
    }

    handleResetSelection(){   
        this.selectedFieldsValue='';
        this.template.querySelector('lightning-datatable').selectedRows=[];
    }
}