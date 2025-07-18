import { LightningElement, track } from 'lwc';

export default class Calculator extends LightningElement {
    numbers = [0,1, 2, 3, 4, 5, 6, 7, 8, 9];
    operators = ['+', '-', '*', '/'];
    @track displayValue = '';

    handleButtonClick(event) {
        console.log("event>>>>",event)
        const value = event.target.label;
        this.displayValue += value;
    }

    handleSubmit() {
        try {
            this.displayValue = eval(this.displayValue).toString();
        } catch (error) {
            this.displayValue = 'Error: ' + error;
        }
    }

    clearDisplay(){
        this.displayValue='';
    }
}
