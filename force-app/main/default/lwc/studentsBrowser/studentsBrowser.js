import { LightningElement, wire } from 'lwc';
import getMethod from '@salesforce/apex/MyLWCController.getMethod';

export default class StudentsBrowser extends LightningElement {

    maxRecords = 10;
    // @wire(getMethod, {maxRecords : "$maxRecords"}) accounts;

    
    accounts = [];
    error;

    handleClick() {
        const inputElement = this.template.querySelector('lightning-input');
        const value = parseInt(inputElement.value, 10);

        if (!isNaN(value) && value > 0) {
            this.maxRecords = value; // triggers rewire automatically
        }
    }

    @wire(getMethod, { maxRecords: "$maxRecords" })
    wiredAccounts({ data, error }) { 
        console.log("data>>>>",data)
        console.log("errors>>>>",error)
        if (data) {
            this.accounts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.accounts = [];
        }
    }
    

}