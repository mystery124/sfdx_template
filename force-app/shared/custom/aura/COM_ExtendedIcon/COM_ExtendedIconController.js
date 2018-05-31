({
    doneRendering: function(component, event, helper) {
        if (!component.get('v.isDoneRendering')) {
            component.set('v.isDoneRendering', true);

            var uniqueId = helper.generateUniqueId(component);

            var color = component.get('v.color');
            if (!$A.util.isUndefinedOrNull(color)) {
                helper.createStyle(component, color, uniqueId);
            }
        }
    },

    toggleTooltip: function(component) {
        component.set('v.showTooltip', !component.get('v.showTooltip'));
    }
})