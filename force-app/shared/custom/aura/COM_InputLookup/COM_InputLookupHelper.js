({
    searchByName: function(component) {
        var parameters = {
            sObjectType: component.get('v.sObjectName'),
            searchTerm: component.get('v.searchTerm')
        }

        this.showLoader(component);
        this.callServer(
            component,
            'c.searchSObjectsByName',
            parameters,
            this.processSearchResult.bind(this, component),
            null,
            true,
            true
        );
    },

    processSearchResult: function(component, result) {
        component.set('v.searchResults', result);
        this.showResults(component);
        this.setFixedResultPosition(component);
        this.hideLoader(component);
    },

    setDefaultValue: function(component) {
        var parameters = {
            sObjectType: component.get('v.sObjectName'),
            searchId: component.get('v.value')
        }

        this.showLoader(component);
        this.callServer(
            component,
            'c.getSObjectById',
            parameters,
            this.processSetDefaultValueResult.bind(this, component),
            null,
            true
        );
    },

    processSetDefaultValueResult: function(component, result) {
        component.set('v.searchTerm', result.name);
        this.hideLoader(component);
        this.validateSearchInput(component);
    },

    showLoader: function(component) {
        component.set('v.isLoading', true);
    },

    hideLoader: function(component) {
        component.set('v.isLoading', false);
    },

    showResults: function(component) {
        component.set('v.showResults', true);
    },

    hideResults: function(component) {
        component.set('v.searchResults',[]);
        component.set('v.showResults', false);
    },

    selectItem: function(component, event) {
        var item = event.currentTarget;
        this.hideResults(component);
        component.set('v.searchTerm', item.dataset.name);
        component.set('v.value', item.dataset.value);
    },

    valueExistsButNoTerm: function(component) {
        return ! $A.util.isEmpty(component.get('v.value')) && $A.util.isEmpty(component.get('v.searchTerm'));
    },

    validateSearchInput: function(component) {
        if($A.util.isEmpty(component.get('v.value')) && ! $A.util.isEmpty(component.get('v.searchTerm'))){
            component.set('v.searchTerm', '');
        }

        component.find('searchInput').showHelpMessageIfInvalid();
        component.set('v.validity', component.find('searchInput').get('v.validity'));
    },

    setFixedResultPosition: function (component) {
        var mainDiv = component.find('mainContainer');
        var dropdown = component.find('searchResult').getElement();
        var coords = mainDiv.getElement().getBoundingClientRect();
        var left = coords.left;
        var top = coords.bottom;

        if($A.util.isUndefinedOrNull(dropdown)){
            return;
        }

        dropdown.style.position = 'fixed';
        dropdown.style.top = top + 'px';
        dropdown.style.left = left + 'px';
        dropdown.style.width = mainDiv.getElement().offsetWidth + 'px';
        dropdown.style.maxWidth = mainDiv.getElement().offsetWidth + 'px';

        var dropdownHeight = this.getHeightOfNonVisibleElement(dropdown);
        var dropdownNeededHeight = top + dropdownHeight;
        if(dropdownNeededHeight > window.innerHeight){
            dropdown.style.top = window.innerHeight - dropdownHeight + 'px';
        }
    },

    getHeightOfNonVisibleElement: function (element) {
        element.style.visibility = 'hidden';
        element.style.display = 'block';

        var height = element.offsetHeight;

        element.style.display = null;
        element.style.visibility = null;

        return height;
    },
})