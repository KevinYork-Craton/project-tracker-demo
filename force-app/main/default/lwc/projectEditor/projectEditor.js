import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Project__c.Name';
import STATUS_FIELD from '@salesforce/schema/Project__c.Status__c';
import BUDGET_FIELD from '@salesforce/schema/Project__c.Budget__c';
import DUE_DATE_FIELD from '@salesforce/schema/Project__c.Due_Date__c';
import COMPLETED_DATE_FIELD from '@salesforce/schema/Project__c.Completed_Date__c';

export default class ProjectEditor extends LightningElement {
    @api recordId;
    @api objectApiName;

    isEditing = false;
    viewKey = 0;

    editableFields = [NAME_FIELD, STATUS_FIELD, BUDGET_FIELD, DUE_DATE_FIELD].map((f) => f.fieldApiName);
    completedDateField = COMPLETED_DATE_FIELD.fieldApiName;
    allFields = [...this.editableFields, this.completedDateField];

    handleEdit() {
        this.isEditing = true;
    }

    handleCancel() {
        this.isEditing = false;
    }

    async handleSuccess() {
        this.isEditing = false;
        // The trigger may have changed fields (e.g. Completed Date); refresh the view and the rest of the page.
        this.viewKey += 1;
        await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.dispatchEvent(new ShowToastEvent({ title: 'Project saved', variant: 'success' }));
    }

    handleError() {
        // lightning-messages shows the details (e.g. "Budget cannot be negative.") inside the form.
        this.dispatchEvent(new ShowToastEvent({ title: 'Save failed', message: 'See the form for details.', variant: 'error' }));
    }
}
