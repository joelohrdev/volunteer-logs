import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLogs from '@salesforce/apex/VolunteerLogController.getLogs';
import addLog from '@salesforce/apex/VolunteerLogController.addLog';

export default class VolunteerTracker extends LightningElement {
    logResult;
    logs = [];
    isLoading = true;
    hours;
    activityDate;
    notes;
    isSubmitting = false;

    @wire(getLogs)
    wiredLogs(result) {
        this.logsResult = result;
        this.isLoading = false;
        if (result.data) {
            this.logs = result.data;
        } else if (result.error) {
            this.showError('Could not load logs', result.error);
        }
    }

    get hasLogs() {
        return this.logs && this.logs.length > 0;
    }

    handleHours(e) { this.hours = e.target.value; }
    handleDate(e) { this.activityDate = e.target.value; }
    handleNotes(e) { this.notes = e.target.value; }

    async handleSubmit() {
        if (!this.activityDate || !this.hours) {
            this.showToast('Missing info', 'Date and hours are required', 'warning');
            return;
        }
        this.isSubmitting = true;
        try {
            await addLog({ activityDate: this.activityDate, hours: this.hours, notes: this.notes });
            this.showToast('Logged', 'Volunteer hours saved.', 'success');
            this.hourse = null;
            this.notes = null;
            await refreshApex(this.logsResult);
        } catch (e) {
            this.showError('Could not save log', e);
        } finally {
            this.isSubmitting = false;
        }
    }

    showError(title, error) {
        const message = error?.body?.message || 'Unkown error';
        this.showToast(title, message, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}