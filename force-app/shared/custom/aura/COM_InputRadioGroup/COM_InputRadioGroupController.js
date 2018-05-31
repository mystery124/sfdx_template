({
    handleChange: function(component, event) {
        var value = component.get('v.value');

        value = $A.util.isUndefined(value) ? null : value;
        component.set('v.privateValue', value);
    },

    handleRadioChange: function (component, event) {
        var value = parseInt(event.getSource().get('v.value'), 10);

        if(component.get('v.isBoolean')) {
            component.set('v.value', value === 0);
        } else {
            var options = component.get('v.options');
            component.set('v.value', options[value].value);
        }
        component.set('v.privateValue', value === 0);
    },
})