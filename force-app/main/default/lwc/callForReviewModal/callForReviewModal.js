import { LightningElement, api, track, wire } from 'lwc';
import getRelatedDocuments from '@salesforce/apex/CallForReviewWithFilesController.getRelatedDocuments';
import submitReview from '@salesforce/apex/CallForReviewWithFilesController.submitReview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CallForReviewModal extends LightningElement {
    @api recordId;
    @track documentSections = [];
    @track missingInfoDescription = ''; // Overall missing info description
    @track requestedDocInputs = {}; // { Account: '...', Contact: '...', WorkOrder: '...' }

    selectedFileIds = new Set(); // more efficient for lookups
    requestedDocs = [];
    
    // Missing info for each section
    accountMissingInfo = '';
    contactMissingInfo = '';
    workOrderMissingInfo = '';
    
    @wire(getRelatedDocuments, { workOrderId: '$recordId' })
    wiredDocuments({ error, data }) {
        if (data) {
            console.log("recordId>>>>", this.recordId);
            console.log("result>>>>>", data);
            this.documentSections = [
                { label: 'Account', type: 'Account', files: data.Account || [] },
                { label: 'Contact', type: 'Contact', files: data.Contact || [] },
                { label: 'Work Order', type: 'WorkOrder', files: data.WorkOrder || [] }
            ];
        } else if (error) {
            console.error('Error fetching documents:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to load documents',
                variant: 'error'
            }));
        }
    }
    
get documentSectionsWithSelection() {
    return this.documentSections.map(section => {
        const fullLabel = `${section.label} Files`;
        const placeholder = `Describe missing information for ${section.label} files...`;
        const inputValue = this.requestedDocInputs[section.type] || '';

        return {
            ...section,
            fullLabel,
            placeholder,
            inputValue,
            files: section.files.map(file => ({
                ...file,
                isSelected: this.selectedFileIds.has(file.Id)
            }))
        };
    });
}


    
    handleMissingInfoDescriptionChange(e) {
        this.missingInfoDescription = e.target.value;
        console.log("missingInfoDescription>>>>>", this.missingInfoDescription);
    }
    
    handleSectionMissingInfoChange(e) {
        const sectionType = e.target.dataset.section;
        const value = e.target.value;
        
        if (sectionType === 'Account') {
            this.accountMissingInfo = value;
        } else if (sectionType === 'Contact') {
            this.contactMissingInfo = value;
        } else if (sectionType === 'WorkOrder') {
            this.workOrderMissingInfo = value;
        }
        
        console.log(`${sectionType} missing info:`, value);
    }
    
    handleCheckboxChange(e) {
        const fileId = e.target.dataset.id;
        if (e.target.checked) {
            this.selectedFileIds.add(fileId);
        } else {
            this.selectedFileIds.delete(fileId);
        }
        
        // Force reactive getter update
        this.selectedFileIds = new Set(this.selectedFileIds);
    }
    
handleRequestInput(e) {
    const type = e.target.dataset.type;
    const value = e.target.value;
    this.requestedDocInputs = {
        ...this.requestedDocInputs,
        [type]: value
    };
}

    
handleSubmit() {
    const requestedDocs = Object.entries(this.requestedDocInputs)
        .filter(([type, name]) => name && name.trim())
        .map(([type, name]) => ({ type, name: name.trim() }));

    console.log("requestedDocs>>>>", requestedDocs);

    const requestedNames = requestedDocs.map(d => d.name);
    const requestedTypes = requestedDocs.map(d => d.type);
    const selectedIdsArray = Array.from(this.selectedFileIds);

    submitReview({
        workOrderId: this.recordId,
        missingInfoDescription: this.missingInfoDescription,
        selectedFileIds: selectedIdsArray,
        requestedFileNames: requestedNames,
        requestedFileTypes: requestedTypes,
        accountMissingInfo: this.accountMissingInfo,
        contactMissingInfo: this.contactMissingInfo,
        workOrderMissingInfo: this.workOrderMissingInfo
    }).then(() => {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Review submitted successfully',
            variant: 'success'
        }));
    }).catch(error => {
        console.error('Error submitting review:', error);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.body?.message || 'Failed to submit review',
            variant: 'error'
        }));
    });
}

}