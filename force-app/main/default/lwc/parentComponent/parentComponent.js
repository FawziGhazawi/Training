import { LightningElement, api } from 'lwc';

export default class ParentComponent extends LightningElement {
    selectedCount = 0;

    handleChildSelect(event) {
        const childElements = this.template.querySelectorAll('c-child-component');
        this.selectedCount = [...childElements].filter(child => child.selected).length;

        this.dispatchEvent(new CustomEvent('parentupdate', {
            detail: { totalSelected: this.selectedCount },
            bubbles: true,
            composed: true
        }));
    }

    @api
    resetChildren() {
        const childElements = this.template.querySelectorAll('c-child-component');
        childElements.forEach(child => child.resetSelection());
        this.selectedCount = 0;
    }
}
