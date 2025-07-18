import { LightningElement, wire, track } from 'lwc';
import getTopAccounts from '@salesforce/apex/LWCRelatedOppsToAccs.getTopAccounts';

export default class TopAccounts extends LightningElement {
    @track accounts = [];
    @track error;
    filterAmount;

    @wire(getTopAccounts)
    wiredAccounts({ data, error }) {
        if (data) {
            this.accounts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.accounts = [];
        }
    }

    handleInputChange(event) {
        const value = event.detail.value;
        this.filterAmount = value ? parseFloat(value) : null;
    }

    get filteredAccounts() {
        if (!this.accounts) return [];
        if (!this.filterAmount) return this.accounts;

        return this.accounts.filter(acc => acc.totalAmount >= this.filterAmount);
    }

    get errorMessage() {
        if (!this.error) return '';
        if (this.error.body && this.error.body.message) {
            return this.error.body.message;
        }
        return JSON.stringify(this.error);
    }
}
