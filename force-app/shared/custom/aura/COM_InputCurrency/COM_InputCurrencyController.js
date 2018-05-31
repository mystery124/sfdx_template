({
    showHelpMessageIfInvalid: function(component) {
        var currencyInput = component.find('currencyInput');
        currencyInput.showHelpMessageIfInvalid();
        component.set('v.validity', currencyInput.get('v.validity'));
    },
})