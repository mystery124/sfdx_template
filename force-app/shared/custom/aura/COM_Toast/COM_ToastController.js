({
    close: function(component, event, helper) {
        var toaster = component.find('toaster');
        $A.util.addClass(toaster, 'slds-hide');
        $A.util.removeClass(toaster, 'showToast');
    },

    showToast: function(component, event) {
        var title = event.getParam('title');
        var message = event.getParam('message');
        var type = event.getParam('type');

        if($A.util.isUndefinedOrNull(title) || $A.util.isUndefinedOrNull(message) ||
             $A.util.isUndefinedOrNull(type)) {
            return;
        }

        component.set('v.title', title);
        component.set('v.message', message);
        component.set('v.type', type);

        var toaster = component.find('toaster');
        $A.util.removeClass(toaster, 'slds-hide');
        $A.util.addClass(toaster, 'showToast');

        window.setTimeout(
            $A.getCallback(function() {
                if(component.isValid()) {
                    $A.util.removeClass(toaster, 'showToast');
                    $A.util.addClass(toaster, 'slds-hide');
                }
            }), 10000
        );
    },
})