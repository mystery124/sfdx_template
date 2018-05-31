({
    doInit: function(component, event, helper) {
        var workspaceAPI = component.find('workspace');
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            component.set('v.tabId', tabId);

            workspaceAPI.getFocusedTabInfo().then(function(response) {
                helper.checkIfIsOnFocusedTab(component, response.tabId);
            });
        });
    },

    doClose: function (component, event, helper) {
        helper.closeDialog(component);
    },

    handleBackgroundClick: function (component, event, helper) {
        if( ! helper.isTargetDivAndContainsBackgroundClass(event.target)){
            return;
        }

        var modalBody = component.find('modal-body');
        var coords = modalBody.getElement().getBoundingClientRect();

        if (event.clientX < coords.left || event.clientX > coords.right || event.clientY < coords.top || event.clientY > coords.bottom) {
            helper.closeDialog(component);
        }
    },

    onTabFocused: function(component, event, helper) {
        helper.checkIfIsOnFocusedTab(component, event.getParam('currentTabId'));
    }
})