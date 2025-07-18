import getAccounts from '@salesforce/apex/LWCRelatedOppsToAccs.getAccounts';
import { LightningElement, wire, api, track } from 'lwc';
import getRelatedOpps from '@salesforce/apex/LWCRelatedOppsToAccs.getRelatedOpps';

export default class RelatedOppsToAccs extends LightningElement {
    
    selectedAccount = '';
    @track accounts = [];
    @track opportunities = [];
    error;
    
    @track selectedAccKey = '';
    
        columns = [
        { label: 'Opportunity Name', fieldName: 'Name', type: 'text' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' },
        { label: 'Stage', fieldName: 'StageName', type: 'text' }
    ];


    @wire(getAccounts)
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
    
    get accOptions() {
        console.log("accounts>>>>", this.accounts);
        if (!this.accounts || this.accounts.length === 0) return [];
        
        return this.accounts.map(account => {
            return {
                label: account.Name,
                value: account.Id
            };
        });
    }
    
    
    handleAccChange(event) {
        this.selectedAccKey = event.detail.value;
        console.log('Selected Account Id:', this.selectedAccKey);
        this.fetchOpportunities();


    }

    fetchOpportunities() {
        if (!this.selectedAccKey) return;
        getRelatedOpps({ accId: this.selectedAccKey })
            .then(result => {
                this.opportunities = result.map(opp => {
                    return {
                        ...opp,
                        _children: [], // needed for tree grid even if no children
                        cssClass: opp.StageName === 'Closed Lost' ? 'closed-lost' : ''
                    };
                });
                console.log("opps>>>>>",this.opportunities)
                this.error = undefined;
            })
            .catch(error => {
                this.opportunities = [];
                this.error = error;
            });
    }

    get styledGridData() {
        return this.opportunities;
    }

    get errorMessage() {
    if (!this.error) return '';
    if (this.error.body && this.error.body.message) {
        return this.error.body.message;
    } else if (this.error.message) {
        return this.error.message;
    } else {
        return JSON.stringify(this.error);
    }
}

    
}