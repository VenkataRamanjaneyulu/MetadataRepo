import { LightningElement, wire, track } from 'lwc';
import getRoles from '@salesforce/apex/RoleHierarchyCtrl.getRoles';

export default class RoleHierarchy extends LightningElement {
    @track roles;
    @track error;

    @wire(getRoles)
    wiredRoles({ error, data }) {
        if (data) {
            console.log('roles are',JSON.parse(data));
            this.roles = JSON.parse(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.roles = undefined;
        }
    }
}