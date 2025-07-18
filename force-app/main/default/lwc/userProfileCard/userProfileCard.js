import { LightningElement, track } from 'lwc';

export default class UserProfileCard extends LightningElement {
    users = {
        user1: {
            name: 'User1Name',
            title: 'User1JobTitle',
            email: 'User1Email',
            status: 'Online'
        },
        user2: {
            name: 'User2Name',
            title: 'User2JobTitle',
            email: 'User2Email',
            status: 'Offline'
        }
    };

    @track selectedUserKey = 'user1';

    get selectedUser() {
        return this.users[this.selectedUserKey];
    }

    get statusButtonStyle() {
        return this.selectedUser.status === 'Online' ? 'slds-button slds-button_success' : 'slds-button slds-button_destructive';
    }

    get userOptions() {
        return [
            { label: 'User 1', value: 'user1' },
            { label: 'User 2', value: 'user2' }
        ];
    }

    handleUserChange(event) {
        this.selectedUserKey = event.detail.value;
    }

    toggleStatus() {
        const user = this.users[this.selectedUserKey];
        user.status = user.status === 'Online' ? 'Offline' : 'Online';
        this.users = { ...this.users };
    }
}
