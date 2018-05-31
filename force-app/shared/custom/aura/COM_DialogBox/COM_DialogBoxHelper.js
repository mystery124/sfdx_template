({
    closeDialog: function(component) {
        component.set('v.isOpen', false);
    },

    isTargetDivAndContainsBackgroundClass: function(target) {
        return !$A.util.isUndefinedOrNull(target) 
            && target.nodeName === 'DIV' 
            && ($A.util.hasClass(target, 'slds-modal') || $A.util.hasClass(target, 'slds-modal__container'));
    },

    checkIfIsOnFocusedTab: function(component, focusedTabId) {
        component.set('v.isOnFocusedTab', focusedTabId === component.get('v.tabId'));
    }
})