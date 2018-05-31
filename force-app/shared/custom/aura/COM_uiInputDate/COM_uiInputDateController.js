({
    showHelpMessageIfInvalid: function(component, event, helper) {
        var value = component.find('inputField').get('v.value');

        if (component.get('v.required') && $A.util.isEmpty(value)) {
            component.set('v.error', $A.get('$Label.c.CompleteThisField'));
            component.set('v.validity.valid', false);
        } else if(helper.isValidFormat(component, value)){
            var isValid = true;

            if(component.get('v.maxDate')){
                isValid = helper.validateMaxDate(component, value);
            }

            if (isValid && component.get('v.minDate')) {
                isValid = helper.validateMinDate(component, value);
            }

            if (isValid) {
                component.set('v.error', '');
            }
        }
    },
})