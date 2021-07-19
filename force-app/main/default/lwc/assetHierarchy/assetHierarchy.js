import { LightningElement,track,wire,api } from 'lwc';
import getAssets from '@salesforce/apex/AssetHierarchyController.getAssets';


export default class AssetHierarchy extends LightningElement {
    @track gridColumns = [
        {
            type: 'text',
            fieldName: 'Name',
            label: 'Name'
        },
        {
            type: 'text',
            fieldName: 'ParentId',
            label: 'Parent Id'
        },
        {
            type: 'text',
            fieldName: 'Product2Id',
            label: 'Product2Id'
        },
        {
            type: 'number',
            fieldName: 'AssetLevel',
            label: 'Asset Level'
        }
    ];
    @track gridData;
    @api recordId=null;

    @wire(getAssets,{ accountId: '$recordId' })
    wiredAssetss({ error, data }) {
        if ( data ) {
            console.log('recordid is ===>',this.recordId);
            var tempjson = JSON.parse(JSON.stringify(data).split('items').join('_children'));
            console.log('tempjson is =====>',tempjson);
            this.gridData = tempjson;
        } else if ( error ) {          
            if ( Array.isArray( error.body ) )
                console.log( 'Error is ' + error.body.map( e => e.message ).join( ', ' ) );
            else if ( typeof error.body.message === 'string' )
                console.log( 'Error is ' + error.body.message );
        }
    }

    clickToExpandAll( e ) {
        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.expandAll();
    }
 
    clickToCollapseAll( e ) {
        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.collapseAll();
      
    }

}


