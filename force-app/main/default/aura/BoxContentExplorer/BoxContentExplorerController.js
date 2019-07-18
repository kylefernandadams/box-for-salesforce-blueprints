({
    doInit : function(component, event, helper) {
        var action = component.get("c.getContentExplorerMap");
        var recordId = component.get("v.recordId");

        action.setParams({ recordId: recordId });
        action.setCallback(this, function(response) {
            var contentExplorerMap = response.getReturnValue();            
            var downscopedToken = contentExplorerMap.downscopedToken; 
            var folderId = contentExplorerMap.folderId;
    
            if(folderId != null) {
                var baseURL = window.location.origin;
                var previewResource = $A.get("$Resource.preview");
                var logoUrl = component.get("v.logoUrl");
                var explorer = new Box.ContentExplorer();
                var explorerContainer = component.find("explorer-container").getElement();
                explorer.show(folderId, downscopedToken, {
                    container: explorerContainer,
                    logoUrl: logoUrl,
                    autoFocus: true,
                    canPreview: true,
                    canDownload: true,
                    canUpload: true,
                    canCreateNewFolder: true,
                    canDelete: true,
                    canRename: true,
                    canShare: true,
                    canSetShareAccess: true,
                    staticHost: baseURL,
                    contentPreviewProps: {
                        staticPath: previewResource,
                        previewLibraryVersion: '2.12.0',
                        showAnnotations: true,
                        contentSidebarProps: {
                            detailsSidebarProps: {
                                hasNotices: true,
                                hasProperties: true,
                                hasAccessStats: true,
                                hasVersions: true
                            },
                            hasActivityFeed: true,
                            hasSkills: true,
                            hasMetadata: true
                        },
                        contentOpenWithProps: {
                            show: false
                        }
                    }
                });
            }
        });
        $A.enqueueAction(action);
    }
})
