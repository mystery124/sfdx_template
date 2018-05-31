({
    handleValueChange: function(component, event, helper) {
        if( ! component.get('v.isInitiated') && helper.valueExistsButNoTerm(component)){
            helper.setDefaultValue(component);
            component.set('v.isInitiated', true);
        }
    },

    handleSearchChange : function(component, event, helper) {
        var searchTerm = component.get('v.searchTerm');

        if(component.get('v.isInitiated') && $A.util.isEmpty(searchTerm)){
            component.set('v.value', null);
            helper.hideResults(component);
        }else if (searchTerm && searchTerm.length > 1){
            helper.searchByName(component);
        }else{
            helper.hideResults(component);
        }
    },

    handleResultSelect: function(component, event, helper) {
        helper.selectItem(component, event);
    },

    handleOnBlur: function(component, event, helper) {
        if( ! component.get('v.isMouseOverResults')){
            window.setTimeout($A.getCallback(function() {
                component.set('v.showResults', false);
            }), 1000);
        }
    },

    showHelpMessageIfInvalid: function(component, event, helper) {
        helper.validateSearchInput(component);
    },

    handleResultMouseOver: function(component, event, helper) {
        component.find('searchInput').focus();
        component.set('v.isMouseOverResults', true);
    },

    handleResultMouseOut: function(component, event, helper) {
        component.set('v.isMouseOverResults', false);
    },
})