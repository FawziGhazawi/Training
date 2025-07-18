import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const fields = [
    'Candidate__c.First_Name__c',
    'Candidate__c.Last_Name__c',
    'Candidate__c.City__c',
    'Candidate__c.Country__c',
    'Candidate__c.State_Province__c',
    'Candidate__c.Zip_Postal_Code__c'
];

export default class CandidateLocation extends LightningElement {
    @api recordId;
    @track name;
    @track mapMarkers = [];

    @wire(getRecord, { recordId: '$recordId', fields })
    loadCandidate({ error, data }) {
        if (error) {
            // TODO: handle error
        } else if (data) {
            // Get Candidate data
            this.name = data.fields.First_Name__c.value + ' ' + data.fields.Last_Name__c.value;

            // Transform Candidate data into map markers
            this.mapMarkers = [{
                location: {
                    City: data.fields.City__c.value,
                    Country: data.fields.Country__c.value,
                    PostalCode: data.fields.Zip_Postal_Code__c.value,
                    State: data.fields.State_Province__c.value
                },
                title: this.name,
                description: 'Candidate Location'
            }];
        }
    }

    get cardTitle() {
        return (this.name) ? `${this.name}'s location` : 'Candidate location';
    }
}