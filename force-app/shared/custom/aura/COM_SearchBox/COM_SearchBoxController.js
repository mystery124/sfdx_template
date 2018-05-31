({
    doInit: function(component, event, helper) {
        var selectedValue = component.get('v.searchText');
        if(!$A.util.isUndefinedOrNull(selectedValue)) {
            helper.setSearchInput(component, selectedValue);
        }
    },

    search: function(component, event, helper) {
        var searchText = component.find('searchInput').get('v.value');

        if(event.getParams().keyCode == 13){
            component.set('v.searchText', searchText);
            component.set('v.isManualSearch', true);
        }
    },

    clearBox: function(component, event, helper) {
        helper.setSearchInputValue(component, '');
        component.set('v.searchText', '');
    },

    setSearchInput: function(component, event, helper) {
        var value = event.getParam('value');
        helper.setSearchInput(component, value);
    }
})