({
    dynamicComponents: [],

    createDynamicComponent: function(component, containerAuraId, dynamicComponentName, params, callback, mainContainer) {
        var componentContainer = mainContainer || 'mainContainer';
        var componentInstanceList = component.find(componentContainer).find({ instancesOf: "c:" + dynamicComponentName });
        var componentInstance = componentInstanceList.length > 0 ? componentInstanceList[0] : null;
        var dynamicComponentKey = component.getGlobalId() + dynamicComponentName;

        if(this.dynamicComponents.indexOf(dynamicComponentKey) === -1
            && $A.util.isUndefinedOrNull(componentInstance)
        ) {
            this.dynamicComponents.push(dynamicComponentKey);
            $A.createComponent(
                'c:' + dynamicComponentName,
                params,
                function (newComponent, status, errorMessage) {
                    if (status === 'SUCCESS') {
                        var container = component.find(containerAuraId);
                        var containerBody = container.get('v.body');
                        containerBody.push(newComponent);
                        container.set('v.body', containerBody);

                        if (typeof callback === "function") {
                            callback(newComponent);
                        }
                    } else {
                        this.showToast('error', $A.get("$Label.c.Error"), errorMessage);
                    }
                }
            );
        }else if(componentInstance && typeof callback === "function"){
            callback(componentInstance);
        }
    },

    callServer: function (cmp, actionName, parameters, onSuccess, onError, isStorable, isAbortable, isBackground){
        var action = cmp.get(actionName);
        if(parameters){
            action.setParams(parameters);
        }
        if(isAbortable){
            action.setAbortable();
        }
        if(isStorable){
            action.setStorable();
        }
        if(isBackground){
            action.setBackground();
        }
        action.setCallback(this, function(response){
            if(response){
                var state = response.getState();
                if(cmp.isValid()){
                    if (state === "SUCCESS"){
                        var result = response.getReturnValue();
                        if (typeof onSuccess === 'function') {
                            onSuccess(result);
                        }
                    } else if(state == "ERROR"){
                        var errors = response.getError();
                        if(!onError){
                            this.handleError(errors);
                        } else {
                            onError(errors);
                        }
                    }
                }
            } else {
                onSuccess();
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type
            });
            toastEvent.fire();
        }
    },
    showCustomToast : function(type, title, message) {
        var toastEvent = $A.get("e.c:COM_ShowToastEvent");
        if(toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type
            });
            toastEvent.fire();
        }
    },
    hideElement: function (cmp, elementId) {
        var elm = cmp.find(elementId);
        $A.util.addClass(elm, 'slds-hide');
    },
    showElement: function (cmp, elementId) {
        var elm = cmp.find(elementId);
        $A.util.removeClass(elm, 'slds-hide');
    },
    clone: function (sourceElm, targetElm) {
        if(targetElm){
            for(var k in targetElm){
                targetElm[k]=undefined;
            }
        }
        for(var k in sourceElm){
            targetElm[k]=sourceElm[k];
        }
    },
    deepClone: function (sourceElm, targetElm) {
        var clone = JSON.parse(JSON.stringify(sourceElm));
        this.clone(clone, targetElm);
    },
    refreshView: function(){
        var refreshEvent = $A.get('e.force:refreshView');
        if(refreshEvent){
            refreshEvent.fire();
        }
    },
    handleError: function(errors){
        if(errors) {
            if(console){
                console.log('errors',errors);
            }
            this.showToast('error', $A.get("$Label.c.Error"), errors[0].message);
        }
    },
    navigateToSObject : function(recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
        if(navEvt && recordId){
            navEvt.setParams({
              "recordId": recordId
            });
            navEvt.fire();
        }
    },

    navigateToSObjectByUrl: function(recordId) {
        var url = window.location.href;
        url = url.split(".com");
        url = url[0] + ".com";
        var objUrl = '/one/one.app#/sObject/recId/view';
        window.location.href = url + objUrl.replace('recId', recordId);
    },

    navigateToSObjectInConsole : function(workspaceAPI, recId, closeFocusedTab) {
        var openTab = function(onSuccess){
            workspaceAPI.openTab({
                recordId: recId,
                focus: true
            }).then(function(response) {
                if(onSuccess){
                    onSuccess();
                }
            }).catch(function(error) {
                if(console) {
                  console.log(error);
                }
            });
        };
        if(closeFocusedTab) {
            workspaceAPI.getFocusedTabInfo()
            .then(function(response) {
                openTab(function(){
                    workspaceAPI.closeTab({tabId: response.tabId});
                });
            }).catch(function(error) {
                if(console) {
                    console.log(error);
                }
            });
        } else {
            openTab();
        }
    },

    getParameterFromUrlByName : function (name, url) {
        if(!url) {
            url = window.location.href;
        }
        name = name.replace(/[\[\]]/g, "\\$&");

        var regex = new RegExp("[?&#]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);

        if(!results) {
            return null;
        }

        if(!results[2]) {
            return '';
        }
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

    setLabelForCurrentTab: function(component, label, iconName) {
        var workspaceAPI  = component.find('workspace');
        workspaceAPI.getEnclosingTabId()
            .then(function(tabId) {
                workspaceAPI.setTabLabel({
                    tabId: tabId,
                    label: label
                });
                workspaceAPI.setTabIcon({
                    tabId: tabId,
                    icon: iconName
                });
        });
    },

    deepCloneArray: function(array) {
        return array.map(obj => Object.assign({}, obj));
    }
    
})