({
    generateUniqueId: function(component) {
        var uniqueId = Math.round((new Date()).getTime() + Math.random() * 10000);
        component.set('v.uniqueId', uniqueId);

        return uniqueId;
    },

    createStyle: function (component, color, uniqueId) {
        var cssElement = component.find('css').getElement();

        if (!$A.util.isUndefinedOrNull(cssElement)) {
            cssElement.innerHTML = '.extended-icon-' + uniqueId + ' svg { fill: ' + color + '; }';
        }
    }
})
