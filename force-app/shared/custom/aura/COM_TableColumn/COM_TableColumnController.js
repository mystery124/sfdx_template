({
    doInit: function(component) {
        component.set('v.value', component.get('v.items')[component.get('v.index')][component.get('v.column.fieldName')]);
    },

    handleActionClick: function(component) {
        var action = component.get('v.column.action');
        action(
            component,
            component.get('v.items')[component.get('v.index')]
        );
    },
})