import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createAccount from '@salesforce/apex/LWCRelatedOppsToAccs.createAccount';

export default class CreateAccountForm extends NavigationMixin(LightningElement) {
    @track accountName = '';
    @track isLoading = false;
    createdAccountId;

    handleInputChange(event) {
        this.accountName = event.target.value;
    }

    handleCreateAccount() {
        this.isLoading = true;
        createAccount({ accName: this.accountName })
            .then(result => {
                this.createdAccountId = result.Id;
                this.showToast('Success', 'Account created: ' + result.Name, 'success');
                this.accountName = '';
                setTimeout(() => {
                    this.navigateToAccount();
                }, 250);
            })
            .catch(error => {
                const errorMsg = error.body?.message || 'Unknown error';
                console.error('Account creation failed:', error);
                this.showToast('Error', errorMsg, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    navigateToAccount() {
        if (!this.createdAccountId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.createdAccountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissable'
        }));
    }
}
