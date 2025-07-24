import { LightningElement, api, track, wire } from 'lwc';
import getRelatedDocuments from '@salesforce/apex/CallForReviewWithFilesController.getRelatedDocuments';
import submitReview from '@salesforce/apex/CallForReviewWithFilesController.submitReview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CallForReviewModal extends LightningElement {
    @api recordId;
    @track documentSections = [];
    @track missingInfoDescription = ''; // Overall missing info description
    
    selectedFileIds = new Set(); // more efficient for lookups
    
    // Missing info for each section
    accountMissingInfo = '';
    contactMissingInfo = '';
    workOrderMissingInfo = '';
    
    // Dynamic document requests for each section
    @track requestedDocuments = {
        Account: [],
        Contact: [],
        WorkOrder: []
    };
    
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
            const missingInfoLabel = `Missing Information for ${section.label} Files`;
            const requestedDocs = this.requestedDocuments[section.type] || [];

            return {
                ...section,
                fullLabel,
                placeholder,
                missingInfoLabel,
                requestedDocs,
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
    
    handleAddDocumentInput(e) {
        const sectionType = e.target.dataset.section;
        const currentDocs = [...this.requestedDocuments[sectionType]];
        const newId = `${sectionType}_${Date.now()}_${Math.random()}`;
        
        currentDocs.push({
            id: newId,
            value: '',
            label: `Document Request ${currentDocs.length + 1}`
        });
        
        this.requestedDocuments = {
            ...this.requestedDocuments,
            [sectionType]: currentDocs
        };
        
        console.log(`Added new document input for ${sectionType}:`, this.requestedDocuments);
    }
    
    handleRemoveDocumentInput(e) {
        const sectionType = e.target.dataset.section;
        const index = parseInt(e.target.dataset.index);
        const currentDocs = [...this.requestedDocuments[sectionType]];
        
        currentDocs.splice(index, 1);
        
        // Re-label remaining documents
        currentDocs.forEach((doc, idx) => {
            doc.label = `Document Request ${idx + 1}`;
        });
        
        this.requestedDocuments = {
            ...this.requestedDocuments,
            [sectionType]: currentDocs
        };
        
        console.log(`Removed document input for ${sectionType}:`, this.requestedDocuments);
    }
    
    handleRequestInputChange(e) {
        const sectionType = e.target.dataset.section;
        const index = parseInt(e.target.dataset.index);
        const value = e.target.value;
        
        const currentDocs = [...this.requestedDocuments[sectionType]];
        currentDocs[index].value = value;
        
        this.requestedDocuments = {
            ...this.requestedDocuments,
            [sectionType]: currentDocs
        };
        
        console.log(`Updated document input for ${sectionType}[${index}]:`, value);
    }
    
    handleSubmit() {
        // Collect all requested documents from all sections
        const allRequestedDocs = [];
        
        Object.entries(this.requestedDocuments).forEach(([sectionType, docs]) => {
            docs.forEach(doc => {
                if (doc.value && doc.value.trim()) {
                    allRequestedDocs.push({
                        name: doc.value.trim(),
                        type: sectionType
                    });
                }
            });
        });
        
        console.log("All requested docs>>>>", allRequestedDocs);
        
        const requestedNames = allRequestedDocs.map(d => d.name);
        const requestedTypes = allRequestedDocs.map(d => d.type);
        const selectedIdsArray = Array.from(this.selectedFileIds);
        
        // Validation
        if (selectedIdsArray.length === 0 && requestedNames.length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: 'Please select existing files or request new documents',
                variant: 'warning'
            }));
            return;
        }
        
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
            
            // Reset form
            this.resetForm();
        }).catch(error => {
            console.error('Error submitting review:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Failed to submit review',
                variant: 'error'
            }));
        });
    }
    
    resetForm() {
        this.missingInfoDescription = '';
        this.accountMissingInfo = '';
        this.contactMissingInfo = '';
        this.workOrderMissingInfo = '';
        this.selectedFileIds = new Set();
        this.requestedDocuments = {
            Account: [],
            Contact: [],
            WorkOrder: []
        };
    }
}