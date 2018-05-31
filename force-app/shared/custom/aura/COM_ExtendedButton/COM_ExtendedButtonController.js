({
    toggleTooltip : function(component, event, helper) {
        var tooltip = component.find('tooltip');

        if ($A.util.isUndefinedOrNull(tooltip)) {
            return;
        }

        if ($A.util.hasClass(tooltip, 'slds-rise-from-ground')) {
            $A.util.removeClass(tooltip, 'slds-rise-from-ground');
            $A.util.addClass(tooltip, 'slds-fall-into-ground');
        } else {
            $A.util.removeClass(tooltip, 'slds-fall-into-ground');
            $A.util.addClass(tooltip, 'slds-rise-from-ground');
        }
    }
})