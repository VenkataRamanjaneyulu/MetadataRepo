import { LightningElement } from 'lwc';

export default class SearchUtil extends LightningElement {

   filterArrayByKeyword(filterByKeyword,arrayToFilter, filterByProperties, operator){
      if(filterByKeyword != '' || filterByKeyword != null || filterByKeyword != undefined){
         const regex = new RegExp('(^' + filterByKeyword + ')|(.' + filterByKeyword + ')|(' + filterByKeyword + '$)'); 
         const filteredRows  = arrayToFilter.filter(item => {
                if( regex.test( item[filterByProperty].toLowerCase() ) ){
                    return item;        
                }    
            });
         return filteredRows;   
        const filterPropertiesLength = filterByProperties.length;

      }
   }      
}




