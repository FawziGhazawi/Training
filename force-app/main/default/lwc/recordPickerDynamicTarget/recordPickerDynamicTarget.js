import { LightningElement, track } from 'lwc';

export default class RecordPickerDynamicTarget extends LightningElement {
    @track selectedObject = 'Account';
    @track selectedRecordId;
    
    get objectOptions() {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Contact', value: 'Contact' }
        ];
    }
    
    get displayInfo() {
        if (this.selectedObject === 'Account') {
            return {
                primaryField:'Name' ,
                additionalFields: [ 'Industry' ]
            };
        } else if (this.selectedObject === 'Contact') {
            return {
                primaryField: 'Name' ,
                additionalFields: ['Title']
            };
        }
        return {
            primaryField: 'Name'
        };
    }
    
    
    get matchingInfo() {
        if (this.selectedObject === 'Account') {
            return {
                primaryField: { fieldPath: 'Name' },
                additionalFields: [{ fieldPath: 'Type' }]
            };
        } else if (this.selectedObject === 'Contact') {
            return {
                primaryField: { fieldPath: 'Name' },
                additionalFields: [{ fieldPath: 'Phone' }]
            };
        }
        return {
            primaryField: { fieldPath: 'Name' }
        };
    }
    
    
    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        this.selectedRecordId = null;
    }
    
    handleRecordChange(event) {
        this.selectedRecordId = event.detail.recordId;
    }
    
    resetSelection() {
        this.selectedRecordId = null;
    }
}
