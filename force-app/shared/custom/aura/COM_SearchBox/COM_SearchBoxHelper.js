({
    setSearchInputValue: function(component, value) {
        component.find('searchInput').set('v.value', value);
    },

    setSearchInput: function(component, value) {
        if(!$A.util.isUndefinedOrNull(value)) {
            if(value === component.find('searchInput').get('v.value')) {
                return;
            }
            this.setSearchInputValue(component, value);
        }
    }
})