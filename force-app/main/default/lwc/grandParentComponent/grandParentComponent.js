import { LightningElement } from 'lwc';

export default class GrandParentComponent extends LightningElement {
    totalSelections = 0;

    handleParentUpdate(event) {
        this.totalSelections = event.detail.totalSelected;
    }

    handleReset() {
        const parent = this.template.querySelector('c-parent-component');
        parent.resetChildren();
        this.totalSelections = 0;
    }
}
