import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getOpenCases from '@salesforce/apex/CaseManagementController.getOpenCases';
import closeCase from '@salesforce/apex/CaseManagementController.closeCase';

export default class CaseManagement extends LightningElement {
    @track cases = [];
    @track isLoading = false;
    @track error;
    wiredCasesResult;

    // Columns for the data table
    columns = [
        { 
            label: 'Case Number', 
            fieldName: 'CaseNumber', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Subject', 
            fieldName: 'Subject', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Account', 
            fieldName: 'AccountName', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Contact', 
            fieldName: 'ContactName', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Priority', 
            fieldName: 'Priority', 
            type: 'text',
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Status', 
            fieldName: 'Status', 
            type: 'text',
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Created Date', 
            fieldName: 'CreatedDate', 
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit'
            },
            cellAttributes: { alignment: 'center' }
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    {
                        label: 'Close Case',
                        name: 'close_case',
                        iconName: 'utility:close'
                    }
                ]
            }
        }
    ];

    /**
     * Lifecycle hook - called when component is inserted into DOM
     */
    async connectedCallback() {
        await this.loadOpenCases();
    }

    /**
     * Loads open cases using async/await
     */
    async loadOpenCases() {
        this.isLoading = true;
        this.error = undefined;

        try {
            // Using async/await to call Apex method
            const result = await getOpenCases();
            
            // Transform data to include nested field values for display
            this.cases = result.map(caseRecord => ({
                ...caseRecord,
                AccountName: caseRecord.Account ? caseRecord.Account.Name : '',
                ContactName: caseRecord.Contact ? caseRecord.Contact.Name : ''
            }));

            console.log('Open cases loaded successfully:', this.cases.length);

        } catch (error) {
            this.error = error;
            this.cases = [];
            this.showToast('Error', 'Failed to load open cases: ' + error.body.message, 'error');
            console.error('Error loading cases:', error);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Handles row actions (Close Case button click)
     */
    async handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'close_case') {
            await this.handleCloseCase(row.Id);
        }
    }

    /**
     * Closes a case using async/await
     */
    async handleCloseCase(caseId) {
        this.isLoading = true;

        try {
            // Using async/await to call Apex method
            const result = await closeCase({ caseId: caseId });
            
            this.showToast('Success', result, 'success');
            
            // Refresh the cases list after closing a case
            await this.loadOpenCases();

        } catch (error) {
            this.showToast('Error', 'Failed to close case: ' + error.body.message, 'error');
            console.error('Error closing case:', error);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Handles refresh button click
     */
    async handleRefresh() {
        await this.loadOpenCases();
    }

    /**
     * Shows toast notification
     */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    /**
     * Getters for template
     */
    get hasCases() {
        return this.cases && this.cases.length > 0;
    }

    get casesCount() {
        return this.cases ? this.cases.length : 0;
    }
}