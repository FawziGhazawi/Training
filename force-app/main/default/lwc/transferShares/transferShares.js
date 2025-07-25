import { LightningElement, track } from 'lwc';

export default class TransferShares extends LightningElement {
    @track transferFrom = '';
    @track transferTo = '';
    @track typeOfShares = '';
    @track numberOfShares = '';

    // Dropdown options
    transferFromOptions = [
        { label: 'KBC Global', value: 'KBC Global' },
        { label: 'ABSYZ Inc', value: 'ABSYZ Inc' },
        { label: 'Software Company', value: 'Software Company' },
        { label: 'John Smith', value: 'John Smith' },
        { label: 'Sarah Johnson', value: 'Sarah Johnson' }
    ];

    transferToOptions = [
        { label: 'KBC Global', value: 'KBC Global' },
        { label: 'ABSYZ Inc', value: 'ABSYZ Inc' },
        { label: 'Software Company', value: 'Software Company' },
        { label: 'John Smith', value: 'John Smith' },
        { label: 'Sarah Johnson', value: 'Sarah Johnson' }
    ];

    shareTypeOptions = [
        { label: 'Ordinary', value: 'Ordinary' },
        { label: 'Normal', value: 'Normal' },
        { label: 'Preferred', value: 'Preferred' },
        { label: 'Common', value: 'Common' }
    ];

    // Corporate Shareholders Data
    @track corporateShareholders = [
        {
            id: 1,
            name: 'KBC Global',
            registrationNumber: 'UAE45466',
            country: 'UAE',
            typeOfShares: 'Ordinary',
            updatedShares: 1500,
            changeInShares: -500,
            isNegativeChange: true
        },
        {
            id: 2,
            name: 'ABSYZ Inc',
            registrationNumber: 'INR45466',
            country: 'INDIA',
            typeOfShares: 'Normal',
            updatedShares: 4000,
            changeInShares: 0,
            isNegativeChange: false,
            hasSecondRow: true,
            mainRowClass: 'has-second-row',
            nameColumnClass: 'has-second-row-column',
            regColumnClass: 'has-second-row-column',
            countryColumnClass: 'has-second-row-column',
            typeColumnClass: 'has-second-row-column',
            sharesColumnClass: 'has-second-row-column',
            changeColumnClass: 'has-second-row-column',
            secondRow: {
                typeOfShares: 'Ordinary',
                updatedShares: 2000,
                changeInShares: 0
            }
        },
        {
            id: 3,
            name: 'Software',
            registrationNumber: 'UAE4545',
            country: 'UAE',
            typeOfShares: 'Ordinary',
            updatedShares: 500,
            changeInShares: 500,
            isNegativeChange: false,
            isNew: true
        }
    ];

    // Individual Shareholders Data
    @track individualShareholders = [
        {
            id: 1,
            name: 'John Smith',
            passportNumber: 'US123456789',
            nationality: 'American',
            typeOfShares: 'Ordinary',
            numberOfShares: 750
        },
        {
            id: 2,
            name: 'Sarah Johnson',
            passportNumber: 'UK987654321',
            nationality: 'British',
            typeOfShares: 'Normal',
            numberOfShares: 1250
        },
        {
            id: 3,
            name: 'Ahmed Al-Rashid',
            passportNumber: 'AE456789123',
            nationality: 'Emirati',
            typeOfShares: 'Ordinary',
            numberOfShares: 500
        }
    ];

    // Handle form field changes
    handleTransferFromChange(event) {
        this.transferFrom = event.detail.value;
    }

    handleTransferToChange(event) {
        this.transferTo = event.detail.value;
    }

    handleShareTypeChange(event) {
        this.typeOfShares = event.detail.value;
    }

    handleSharesNumberChange(event) {
        this.numberOfShares = event.target.value;
    }

    // Handle transfer button click
    handleTransfer() {
        if (!this.transferFrom || !this.transferTo || !this.typeOfShares || !this.numberOfShares) {
            // Show error message
            this.showToast('Error', 'Please fill all required fields', 'error');
            return;
        }

        if (this.transferFrom === this.transferTo) {
            this.showToast('Error', 'Transfer From and Transfer To cannot be the same', 'error');
            return;
        }

        // Process transfer logic here
        this.showToast('Success', `Successfully transferred ${this.numberOfShares} ${this.typeOfShares} shares from ${this.transferFrom} to ${this.transferTo}`, 'success');
        
        // Reset form
        this.resetForm();
    }

    resetForm() {
        this.transferFrom = '';
        this.transferTo = '';
        this.typeOfShares = '';
        this.numberOfShares = '';
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // Getter for formatted change display
    getChangeDisplay(shareholder) {
        if (shareholder.changeInShares === 0) return '';
        const sign = shareholder.isNegativeChange ? '' : '+ ';
        return `${sign}${Math.abs(shareholder.changeInShares)}`;
    }

    get processedShareholders() {
        return this.corporateShareholders.map(shareholder => {
            const sanitizedChange = Number(shareholder.changeInShares);
            return {
                ...shareholder,
                changeInShares: sanitizedChange,
                isNegativeChange: sanitizedChange < 0,
                secondRowKey: shareholder.id + '-second'
            };
        });
    }


}