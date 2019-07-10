# Box for Salesforce Blueprints
Box for Salesforce Blueprints is a collection of examples designed to work with the Box for Salesforce managed package. These samples are designed to be used for demonstration, development, and test purposes.

## Pre-Requisites

1. Clone this github repo.
2. Setup your Salesforce DX environment: https://trailhead.salesforce.com/en/content/learn/projects/quick-start-salesforce-dx/set-up-your-salesforce-dx-environment
3. Setup VS Code: https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/set-up-visual-studio-code
4. Enable Dev Hub in Salesforce.
5. Install and Configure the Box for Salesforce Managed Package: https://community.box.com/t5/How-to-Guides-for-Integrations/Installing-and-Configuring-Box-For-Salesforce/ta-p/180
    > Note: Dont forget to add the Box VisualForce components to each of the record type layouts.

6. Install the Box Salesforce SDK Unmanaged Package:
    
    * Production/Developer Org: https://cloud.box.com/Box-Apex-SDK
    * Sandbox Org: https://cloud.box.com/Box-Apex-SDK-Sandbox

7. Open the source from this repo in VS Code.
8. In VS Code, use the cmd+shift+p shortcut and select SFDX: Authorize Org
9. Confirm you've successfully authorized your org by listing orgs and their associated status:
```
sfdx force:org:list
```
10. List the installed packaged for your org:
```
sfdx force:package:installed:list -u <username@domain.com>
```
11. Locate the Box for Salesforce package and copy the PACKAGE ID and VERSION into a new dependencies json element of the sfdx-project.json located at the root project directory.

It should looks something like this:
```
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true
    }
  ],
  "namespace": "",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "45.0",
  "dependencies": [
    { 
      "package" : "033700000004yvWAAQ",
      "versionNumber": "3.56.0.1"
    },
    { 
      "package" : "0334P000000kKiUQAU",
      "versionNumber": "1.0.0.1"
    }
  ]
}
```
13. Deploy you project source to either you scratch org or developer org in the next section.

## Deploy to your Org
Push to Scratch Org:
```
sfdx force:source:push
```


Deploy to Developer/Production Org:
```
sfdx force:source:deploy -p force-app -u username@company.com
```

## Box JWT Connection Configuration
1. Open the newly deployed Box Platform Settings tab found in the App Launcher:

![Box Platform Settings tab](/images/1-add-tab.png)

2. Click the New Connectiom button to add a new JWT connection.

![New Connection](/images/2-new-connection.png)

3. Follow the instructions in the New Connection wizard:

![Pre-Requisites](/images/3-prereqs.png)

4. Upload the newly created sfdx_box_config.json

![Configure Part 1](/images/4a-configure.png)

![Configure Part 2](/images/4b-configure.png)

5. Provide a new JWT Connection Name, review the values that were parsed from the JSON file, then click Next.

![Review](/images/5-review.png)

6. Confirm that the Box JWT Connection Test was successful and the Box Service Account Name, Login, and IDs were returned. Finally click Save.

![Connection Test](/images/6-service-account-connection-test.png)

7. Confirm the save worked and the new connection is populated in the data table.

![New Connection Created](/images/7-connection-created.png)

8. Enable Communities, create a new community, and in the Community App Builder add the Box Content Explorer component for a record detail page.
    > Note: The Box Content Explorer will only render folders for records in which a folder has already been created.

![Add Box Content Explorer](/images/8-app-builder-add.png)

![Preview Box Content Explorer](/images/9-app-builder-preview.png)

9. You will most certainly receive CORS errors in the browser console. Go to your application configuration in the Box Developer console and add the appropriate domains found in the browser console error.

![Preview Box Content Explorer](/images/10-box-cors-configuration.png)

## Description of Customizations
1. [CSP Trusted Sites](/force-app/main/default/cspTrustedSites)

    > Why manually configure [CSP Trusted Sites](https://help.salesforce.com/articleView?id=csp_trusted_sites.htm) for Box when you can automate it?

2. Box Platform Connection components
    
    * [Box_Jwt_Connection__c Custom Object](/force-app/main/default/objects/Box_Jwt_Connection__c)
    * [Box Platform Settings Tab](/force-app/main/default/tabs/BoxPlatformTab.tab-meta.xml)
    * [Box Platform Settings Page](/force-app/main/default/flexipage/BoxPlatformPage.flexipage-meta.xml)
    * [Box Platform Settings Page Layout](/force-app/main/default/layouts/Box_Jwt_Connection__c-Layout.layout-meta.xml)
    * [Box Platform Settings Permission Set](/force-app/main/default/permissionsets/BoxPlatform.permissionset-meta.xml)
    * [Box Platform Settings Admin Profile](/force-app/main/default/profiles/Admin.profile-meta.xml)
    * [Box Platform Settings Lightning Web Component](/force-app/main/default/lwc/boxPlatformSettings)
    * [Box Platform Settings Lightning Web Component - BoxJwtConnectionController](/force-app/main/default/classes/BoxJwtConnectionController.cls)
    
3. Box JWT Connection and Token Exchange Logic
    * [Box Connection Handler](/force-app/main/default/classes/BoxConnection.cls)

4. Standard Object Triggers and Corresponding Apex Handlers
    * [Box App User Creation Trigger for Communities Users](/force-app/main/default/triggers/AppUserCreation.trigger)
    * [Box App User Creation Handler](/force-app/main/default/classes/BoxAppUserHandler.cls)
    * [Box Account Folder Creation Trigger](/force-app/main/default/triggers/AccountFolderCreation.trigger)
    * [Box Case Folder Creation Trigger](/force-app/main/default/triggers/CaseTrigger.trigger#L5)
    * [Box Record Folder Creation Handler](/force-app/main/default/classes/BoxRecordFolderHandler.cls)

5. Box UI Elements
    * [Box Content Explorer - Lightning Aura Component](/force-app/main/default/aura/BoxContentExplorer)
    * [Box Content Explorer Controller](/force-app/main/default/classes/BoxContentExplorerController.cls)
    * [Box Content Explorer - Static Resources](/force-app/main/default/staticresources/explorer)
    * [Box Content Preview - Static Resources](/force-app/main/default/staticresources/preview)

6. Large Batch Processing with Salesforce Platform Events
    * [Case Update Trigger](/force-app/main/default/triggers/CaseTrigger.trigger#L9)
    * [Case Closed Event Custom Object](/force-app/main/default/objects/Case_Closed__e)
    * [Case Closed Event Publisher Apex Class](/force-app/main/default/classes/CaseClosedEventPublisher.cls)
    * [Case Closed Event Trigger](/force-app/main/default/triggers/CaseClosedEventTrigger.trigger)
    * [Case Closed Event Subscriber Apex Class](/force-app/main/default/classes/CaseClosedEventSubscriber.cls)
    * [Here's a quick demo video](https://cloud.box.com/s/pnazifgluovtx1exzuej8r2oebkr8fi3)

![Platform Events Example](/images/11-box-sfdc-platform-events.png)

7. Private Key Conversion Script
    * [parse_box_config.py](/scripts/parse_box_config.py)

## Disclaimer
This project is a collection open source examples and should not be treated as an officially supported product. Use at your own risk. If you encounter any problems, please log an [issue](https://github.com/kylefernandadams/box-for-salesforce-blueprints/issues).

## License
 
The MIT License (MIT)

Copyright (c) 2019 Kyle Adams

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
