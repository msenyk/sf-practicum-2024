import { LightningElement, api, track, wire } from 'lwc';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableCells from '@salesforce/apex/ParcelLockerController.getAvailableCells';;
import getOrderFields from '@salesforce/apex/CellOrderController.getOrderFields';
import findOptimalCell from '@salesforce/apex/CellsController.findOptimalCell';
import CELL_FIELD from '@salesforce/schema/CellOrder__c.Cell__c';
import ID_FIELD from '@salesforce/schema/CellOrder__c.Id';
import STATUS_FIELD from '@salesforce/schema/CellOrder__c.State__c';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import SELECTED_CELL_MESSAGE from '@salesforce/messageChannel/SelectedCellMessage__c';
import REFRESH_PARCEL_LOCKER_MESSAGE from '@salesforce/messageChannel/RefreshParcelLockerMessage__c';

export default class AvailableCellsPicker extends LightningElement {
    @api recordId;
    @track cellOptions = []; 
    @track selectedCell; 
    parcelLockerId;
    orderId;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        getOrderFields({ cellOrderId: this.recordId }).then(result => {
            this.parcelLockerId = result.ParcelLocker__c;
            this.orderId = result.Order__c;
            this.fetchAvailableCells();
        });
        this.subscription = subscribe(
            this.messageContext,
            SELECTED_CELL_MESSAGE,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        this.selectedCell = message.cellStatus;
    }
   
    fetchAvailableCells() {
        getAvailableCells({ parcelLockerId: this.parcelLockerId })
            .then(result => {
                this.cellOptions = result;
            })
            .catch(error => {
            });
    }

    handleCellChange(event) {
        this.selectedCell = event.detail.value;
    }

    updateCellOrder(cellId) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[CELL_FIELD.fieldApiName] = cellId;
        fields[STATUS_FIELD.fieldApiName] = "Delivered";

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Cell selected',
                        variant: 'success',
                    }),
                );
                this.fetchAvailableCells();
                let refresh = true;
                publish(this.messageContext, REFRESH_PARCEL_LOCKER_MESSAGE, { refresh });
                
            })
            .catch(error => {
                console.log('Failed to select cell:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to select cell: fields cannot be edited after delivery is completed',
                        variant: 'error',
                    }),
                );
            });
    }

    handleSelectCell() {
        if (this.selectedCell) {
            this.updateCellOrder(this.selectedCell);
        }
    }

    handleSelectOptimalCell() {
        if (this.recordId) {
            this.isLoading = true;
            findOptimalCell({ cellOrderId: this.recordId })
                .then(cellId => {
                    if (cellId) {
                        this.selectedCell = cellId;
                        this.updateCellOrder(cellId);
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Failed to select optimal cell',
                                message: 'Failed to select optimal cell: there is no empty cells suitable for this parcel',
                                variant: 'warning',
                            }),
                        );
                    }
                })
                .catch(error => {
                    console.error('Failed to select optimal cell:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed to select optimal cell: there is no empty cells suitable for this parcel',
                            variant: 'error',
                        }),
                    );
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }
   
    get isSelectButtonDisabled() {
        return !this.selectedCell || this.isLoading;
    }

    get isOptimalButtonDisabled() {
        return !this.recordId || this.isLoading;
    }
}