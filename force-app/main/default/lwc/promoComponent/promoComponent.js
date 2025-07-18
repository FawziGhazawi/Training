import { LightningElement } from 'lwc';

export default class PromoComponent extends LightningElement {

    btn1Name = "Click Me Now!";
    handleClick(){
        console.log("hello component");
        alert(1);
    }
}