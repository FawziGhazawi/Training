import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
    isSelected = false;
    
    handleToggle() {
        this.isSelected = !this.isSelected;
        
        this.dispatchEvent(new CustomEvent('childselect', {
            detail: { selected: this.isSelected },
            bubbles: true,
            composed: true
        }));
    }
    
    @api
    resetSelection() {
        this.isSelected = false;
    }
    
    @api
    get selected() {
        return this.isSelected;
    }
    
    get buttonLabel() {
        return this.isSelected ? 'Deselect' : 'Select';
    }

    get buttonClass() {
        return this.isSelected ? 'selected' : 'deselected';
    }
    
}
