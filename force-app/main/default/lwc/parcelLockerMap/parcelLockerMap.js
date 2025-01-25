import { LightningElement, api, track, wire } from 'lwc';
import getOrderFields from '@salesforce/apex/CellOrderController.getOrderFields';
import getCells from '@salesforce/apex/ParcelLockerController.getCells';
import cell_closed from '@salesforce/resourceUrl/cell_closed';
import cell_open from '@salesforce/resourceUrl/cell_open';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import SELECTED_CELL_MESSAGE from '@salesforce/messageChannel/SelectedCellMessage__c';
import REFRESH_PARCEL_LOCKER_MESSAGE from '@salesforce/messageChannel/RefreshParcelLockerMessage__c';

export default class ParcelLockerMap extends LightningElement {
    @api recordId;
    cells = [];
    orderProducts;
    lockerId;
    rows = [];
    selectedCellId = null;
    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        getOrderFields({ cellOrderId: this.recordId }).then(result => {
            this.lockerId = result.ParcelLocker__c;
            getCells({ lockerId: this.lockerId }).then(result => {
                this.processCells(result);
            });
        });
        this.subscription = subscribe(
            this.messageContext,
            REFRESH_PARCEL_LOCKER_MESSAGE,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        if (message.reDraw) {
            getCells({ lockerId: this.lockerId }).then(result => {
                this.processCells(result);
            });
        };
    }
    
    processCells(cells) {
        const grid = {};

        cells.forEach(cell => {
            const mainPositionMatch = cell.Position__c.match(/^([A-D]-\d+)/);
            const subPositionMatch = cell.Position__c.match(/\((A|B|C|D)-(\d+)\)/);

            if (!mainPositionMatch) return;

            const mainPosition = mainPositionMatch[1];
            const row = mainPosition.split('-')[1];
            if (!grid[row]) {
                grid[row] = [];
            }

            if (subPositionMatch && (row === '4' || row === '6')) {
                const mainCol = mainPosition.split('-')[0];
                const subCol = subPositionMatch[1];
                const subRow = subPositionMatch[2];

                let mainCell = grid[row].find(c => c.name === mainCol);
                if (!mainCell) {
                    const numCols = row === '4' ? 2 : 1;

                    mainCell = {
                        name: mainCol,
                        isSubCell: true,
                        subCells: Array.from({ length: 3 }, (_, i) => ({
                            name: `Row ${i + 1}`,
                            cells: Array.from({ length: numCols }, () => ({
                                name: 'empty',
                                style: '',
                                isEmpty: true,
                                cssClass: 'sub-cell'
                            })),
                        })),
                        cssClass: 'cell'
                    };
                    grid[row].push(mainCell);
                }

                const subRowIndex = parseInt(subRow, 10) - 1;
                const subColIndex = row === '4' ? (subCol === 'A' ? 0 : 1) : 0;

                if (subRowIndex >= 0 && subRowIndex < mainCell.subCells.length) {
                    mainCell.subCells[subRowIndex].cells[subColIndex] = {
                        id: cell.Id,
                        name: cell.Name,
                        style: this.calculateCellStyle(cell.Availability__c, true),
                        position: mainCol + "-" + row + "(" + subCol + "-" + subRow + ")",
                        status: cell.Status__c,
                        availability: cell.Availability__c,
                        imageSrc: cell.Status__c === 'Closed' ? cell_closed : cell_open,
                        availabilityStyle: `color: ${cell.Availability__c === 'Full' ? 'red' : '#00af00'}`,
                        isEmpty: false,
                        statusBoolean: cell.Status__c === 'Closed' ? true : false,
                        isSelected: false,
                        cssClass: 'sub-cell'
                    };
                }
            } else {
                grid[row].push({
                    id: cell.Id,
                    name: cell.Name,
                    style: this.calculateCellStyle(cell.Availability__c, false),
                    position: cell.Position__c,
                    status: cell.Status__c,
                    availability: cell.Availability__c,
                    imageSrc: cell.Status__c === 'Closed' ? cell_closed : cell_open,
                    availabilityStyle: `color: ${cell.Availability__c === 'Full' ? 'red' : '#00af00'}`,
                    isSubCell: false,
                    statusBoolean: cell.Status__c === 'Closed' ? true : false,
                    isSelected: false,
                    cssClass: 'cell'
                });
            }
        });

        this.rows = Object.keys(grid)
            .sort()
            .map(rowKey => ({
                name: `Row ${rowKey}`,
                index: parseInt(rowKey, 10),
                cssClass: `row-${rowKey}`,
                cells: grid[rowKey],
            }));
    }


    calculateCellStyle(availability, isSubCell) {
        let style = '';
        style = 'background-color: #373749;';
        return style;
    }

    getRowClass(index) {
        return `row-${index}`;
    }

    handleCellClick(event) {
        if (!event.target.closest('.cell-content')) {
            return;
        }
        const cellId = event.target.closest('.cell-content').dataset.id;

        this.selectedCellId = cellId;

        this.rows = this.rows.map(row => ({
            ...row,
            cells: row.cells.map(cell => {

                if (cell.isSubCell) {

                    return {
                        ...cell,
                        subCells: cell.subCells.map(subRow => ({
                            ...subRow,
                            cells: subRow.cells.map(subCell => ({
                                ...subCell,
                                isSelected: subCell.id === cellId,
                                cssClass: subCell.id === cellId ? 'sub-cell selected-cell' : 'sub-cell',
                                availability: subCell.availability
                            })),
                        })),
                    };
                } else {

                    return {
                        ...cell,
                        isSelected: cell.id === cellId,
                        cssClass: cell.id === cellId ? 'cell selected-cell' : 'cell',
                        availability: cell.availability
                    };
                }
            }),
        }));
        let isEmpty = false;
        this.rows.forEach(row => {
            row.cells.forEach(cell => {
                if (cell.isSubCell) {

                    cell.subCells.forEach(subRow => {
                        subRow.cells.forEach(subCell => {
                            if (subCell.id === cellId) {
                                isEmpty = subCell.availability === 'Empty';
                            }
                        });
                    });
                } else {

                    if (cell.id === cellId) {
                        isEmpty = cell.availability === 'Empty';
                    }
                }
            });
        });
        let cellStatus = isEmpty ? cellId : null;
        publish(this.messageContext, SELECTED_CELL_MESSAGE, { cellStatus });
    }
}