import getAccounts from '@salesforce/apex/LWCRelatedOppsToAccs.getAccounts';
import getRelatedContacts from '@salesforce/apex/LWCRelatedOppsToAccs.getRelatedContacts';
import updateContact from '@salesforce/apex/LWCRelatedOppsToAccs.updateContact';

import { LightningElement, track, api } from 'lwc';

export default class ContactListEditor extends LightningElement {
    @api recordId;             // Account Id
    @track accounts = [];
    @track contacts = [];
    @track selectedAccKey = '';
    @track isModalOpen = false;
    @track contactToEdit = {};
    @track originalContact ={};
    error;
    
    columns = [
        { label: 'First Name', fieldName: 'FirstName', type: 'text' },
        { label: 'Last Name', fieldName: 'LastName', type: 'text' },
        { label: 'Mobile', fieldName: 'Phone', type: 'phone' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        {
            type: 'button',
            typeAttributes: {
                label: 'Edit',
                name: 'edit',
                title: 'Edit',
                variant: 'brand'
            }
        }
    ];
    
    connectedCallback() {
        getAccounts()
        .then(data => {
            this.accounts = data;
        })
        .catch(error => {
            this.error = error;
        });
        
        if (this.recordId) {
            getRelatedContacts({ accId: this.recordId })
            .then(result => {
                this.contacts = result.map(cnt => ({ ...cnt, _children: [] }));
            })
            .catch(error => {
                this.error = error;
            });
        }
    }
    
    
    get accOptions() {
        return this.accounts.map(acc => ({ label: acc.Name, value: acc.Id }));
    }
    
    // handleAccChange(event) {
    //     this.selectedAccKey = event.detail.value;
    //     this.fetchContacts();
    // }
    
    
    
    handleRowAction(event) {
        if (event.detail.action.name === 'edit') {
            const selected = { ...event.detail.row };
            this.originalContact = { ...selected }; // Save for reset
            this.contactToEdit = selected;
            this.isModalOpen = true;
        }
    }
    
    closeModal() {
        this.isModalOpen = false;
        this.contactToEdit = { ...this.originalContact };
    }
    
    
    handleFieldChange(event) {
        this.contactToEdit[event.target.name] = event.target.value;
    }
    
    saveContact(event) {
        event.preventDefault(); // prevent default form submit
        const fullName = `${this.contactToEdit.FirstName || ''} ${this.contactToEdit.LastName || ''}`.trim();
        console.log("fullName>>>",fullName)
        if (fullName.length > 10) {
            alert('Full name must be 10 characters or fewer.');
            return;
        }
        
        updateContact({ contact: this.contactToEdit })
        .then(() => {
            // Replace the whole contacts array to trigger reactivity
            this.contacts = this.contacts.map(c =>
                c.Id === this.contactToEdit.Id
                ? { ...this.contactToEdit, _children: [] }
                : c
            );
            this.closeModal();
        })
        .catch(error => {
            this.error = error;
        });
    }
    
    get styledGridData() {
        return this.contacts;
    }
    
    get errorMessage() {
        return this.error?.body?.message || this.error?.message || JSON.stringify(this.error);
    }
}
