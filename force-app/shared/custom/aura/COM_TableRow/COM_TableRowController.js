({
    handleCheckboxChange: function(component, event, helper) {
        var event = component.getEvent('COM_TableRowCheckboxEvent');
        event.setParams({
            tableName: component.get('v.tableName'),
            index: component.get('v.index'),
            isChecked: component.get('v.isChecked'),
        });
        event.fire();
    },
})