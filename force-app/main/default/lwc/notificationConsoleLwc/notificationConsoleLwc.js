import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NotificationConsoleLwc extends LightningElement {
    channel = '/event/Notification__e';
    subscription = {};
    @track notifications = [];
    isMuted = false;

    connectedCallback() {
        this.registerErrorListener(); // Register error listener
        this.handleSubscribe(); // Subscribe to the Platform Event channel  
    }

    disconnectedCallback() {
        this.handleUnsubscribe(); // Unsubscribe from the Platform Event channel
    }
    
    // Subscribe to the Platform Event
    handleSubscribe() {

        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));
            this.onReceiveNotification(response); // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channel, -1, messageCallback).then(response => {

            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;

            // Tell the world we're ready
            const event = new ShowToastEvent({
                title: 'Notification Console',
                message: 'Ready to receive notifications'
            });
            this.dispatchEvent(event);              
        });   
    }

    // Unsubscribe from the Platform EVent
    handleUnsubscribe() {
        unsubscribe(this.subscription, response => { // Invoke unsubscribe method of empApi
            console.log('unsubscribe() response: ', JSON.stringify(response)); // Response is true for successful unsubscribe
        });
    }   
    
    // Listen for errors from the empApi component
    registerErrorListener() {
        onError(error => { // Invoke onError empApi method
            console.log('Received error from server: ', JSON.stringify(error)); // Error contains the server-side error
        });
    }
    
    // Extract the message and save to the history
    onReceiveNotification(message) {

        // Extract notification from platform event
        const newNotification = {
            time: message.data.payload.CreatedDate,
            message: message.data.payload.Message__c,
            replayId: message.data.event.replayId
        };

        // Save notification in history
        this.notifications.push(newNotification);   

        // Tell the world
        const event = new ShowToastEvent({
            title: 'Notification Received',
            message: newNotification.message
        });
        this.dispatchEvent(event);        
    }

    // Clear notifications in console app
    onClear() {
        this.notifications = [];
    }

    // Mute toast messages to channel and unsubscribe/resubscribe to channel
    onToggleMute() {
        this.isMuted = !this.isMuted;
        if ( this.isMuted ) {
            this.handleUnsubscribe();
        } else {
            this.handleSubscribe();
        }
    }
    
    get mutedIcon() {
        return (this.isMuted ? 'utility:volume_off' : 'utility:volume_high');
    }

    get mutedTitle() {
        return (this.isMuted ? 'Unmute notifications' : 'Mute notifications');
    }
}