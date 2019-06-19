import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {  deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { reduceErrors } from 'c/ldsUtils';
import getBoxJwtConnectionList from '@salesforce/apex/BoxJwtConnectionController.getBoxJwtConnectionList';
import testJwtConnection from '@salesforce/apex/BoxJwtConnectionController.testJwtConnection';
import createBoxJwtConnection from '@salesforce/apex/BoxJwtConnectionController.createBoxJwtConnection';

export default class BoxPlatformSettings extends LightningElement {
    actions = [
        { label: 'Delete', name: 'delete' },
    ];
    
    jwtDataTableColumns = [
        { label: 'Connection Name', fieldName: 'Connection_Name__c' },
        { label: 'Public Key ID', fieldName: 'Public_Key_ID__c' },
        { label: 'Client ID', fieldName: 'Client_ID__c' },
        { label: 'Client Secret', fieldName: 'Client_Secret__c' },
        { label: 'Enterprise ID', fieldName: 'Enterprise_ID__c' },
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        },
    ];
    
    steps = [
        { label: 'Pre-Requisites', value: 'prereqs' },
        { label: 'Configure', value: 'config' },
        { label: 'Review', value: 'review' },
        { label: 'Connect', value: 'connect' }
    ];
    
    @track error;
    @track tableLoadingState = true;


    // Wire to Apex Box JWT connection class
    @track boxJwtConnectionList;

    // Service account object 
    @track serviceAccount;

    // Progress bar variables
    @track newConnectionModel = false;
    @track progress = 'prereqs';
    @track currentStep = 1;
    @track isPrereq = true;
    @track isConfig = false;
    @track isReview = false;
    @track isConnect = false;

    // JWT Connection variables
    boxAppConfig = '';
    @track fileNotUploaded = true;
    @track jwtConnectionName
    @track enterpriseID;
    @track clientID;
    @track clientSecret;
    @track publicKeyID;
    @track privateKey;

    @wire(getBoxJwtConnectionList)
    wireBoxJwtConnections(results) {
        this.boxJwtConnectionList = results;
        this.tableLoadingState = false;
    }

    handleCreate() {
        this.newConnectionModel = true;
    }

    handleNextClick() {

        if(this.isPrereq) {
            this.isPrereq = false;
            this.isConfig = true;
            this.progress = 'config';
        }
        else if(this.isConfig) {
            this.isConfig = false;
            this.isReview = true;
            this.progress = 'review';
            this.parseBoxConfigJson();
        }
        else if(this.isReview) {
            this.isReview = false;
            this.isConnect = true;
            this.progress = 'connect';
            this.handleTestConnection();
        }
    }

    handleBackClick() {
        if(this.isPrereq) {
            this.enterpriseID = '';
            this.clientID = '';
            this.clientSecret = '';
            this.publicKeyID = '';
            this.privateKey = '';
            this.jwtConnectionName = '';
            this.newConnectionModel = false;
            this.fileNotUploaded = true;
        }
        else if(this.isConfig) {
            this.isConfig = false;
            this.isPrereq = true;
            this.progress = 'prereqs';

        }
        else if(this.isReview) {
            this.isReview = false;
            this.isConfig = true;
            this.progress = 'config';
        }
        else if(this.isConnect) {
            this.isConnect = false;
            this.isReview = true;
            this.progress = 'review';
            this.parseBoxConfigJson();
        }
    }

    handleConfigChange(event) {
        const file = event.detail.files[0];
        const reader = new FileReader();
        reader.addEventListener("load", e => {
            this.boxAppConfig = e.target.result;
            this.fileNotUploaded = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Successfully uploaded Box Developer Application config file. Click Next.',
                    variant: 'success'
                })
            );
        });
        reader.readAsText(file);
    }

    handleNameChange(event) {
        this.jwtConnectionName = event.target.value;
    }

    parseBoxConfigJson() {
        const configJson = JSON.parse(this.boxAppConfig);

        this.enterpriseID = configJson.enterpriseID;
        this.clientID = configJson.boxAppSettings.clientID;
        this.clientSecret = configJson.boxAppSettings.clientSecret;
        this.publicKeyID = configJson.boxAppSettings.appAuth.publicKeyID;
        this.privateKey = configJson.boxAppSettings.appAuth.privateKey;
    }

    handleTestConnection() {
        testJwtConnection({
            enterpriseID: this.enterpriseID, 
            clientID: this.clientID, 
            clientSecret: this.clientSecret, 
            publicKeyID: this.publicKeyID, 
            privateKey: this.privateKey
        })
        .then(result => {
            this.serviceAccount = this.parseJsonPayload(result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'JWT Connection test was sucessful!',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'JWT connection test failed!',
                    message: reduceErrors(error).join(', '),
                    variant: 'error',
                    mode: 'pester'
                })
            );
        });

    }

    handleSave() {
        createBoxJwtConnection({
            jwtConnectionName: this.jwtConnectionName,
            enterpriseID: this.enterpriseID,
            clientID: this.clientID,
            clientSecret: this.clientSecret,
            publicKeyID: this.publicKeyID,
            serviceAccountID: this.serviceAccount.id,
            serviceAccountLogin: this.serviceAccount.login,
            serviceAccountName: this.serviceAccount.name,
            privateKey: this.privateKey
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'New JWT Connection Created',
                    variant: 'success'
                })
            );
            return refreshApex(this.boxJwtConnectionList);
        })
        .then(() => {
            this.isPrereq = true;
            this.isConnect = false;
            this.progress = 'prereqs';
            this.enterpriseID = '';
            this.clientID = '';
            this.clientSecret = '';
            this.publicKeyID = '';
            this.privateKey = '';
            this.jwtConnectionName = '';
            this.newConnectionModel = false;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed to create JWT connection',
                    message: reduceErrors(error).join(', '),
                    variant: 'error',
                    mode: 'pester'
                })
            );
        });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('Found row: ', row);
        console.log('Found row: ', JSON.stringify(row, null, 2));

        switch(actionName) {
            case 'delete':
                this.deleteConnection(row);
                break;
            default:
        }
    }

    deleteConnection(row) {
        deleteRecord(row.Id)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'JWT Connection deleted',
                    variant: 'success'
                })
            );
            return refreshApex(this.boxJwtConnectionList);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed to delete record',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        });
    }



    parseJsonPayload(json) {
        var jsonReturnValue = JSON.parse(json);
        return JSON.parse(jsonReturnValue.jsonString);
    }
}