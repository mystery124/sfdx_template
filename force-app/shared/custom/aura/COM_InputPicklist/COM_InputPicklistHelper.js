({
    markSelectedItems: function(component, values) {
        var options = component.get("v.options_") || [];
        var originalOptions = component.get("v.originalOptions") || [];
        var items = values.split(';');

        options.forEach(function(element) {
            element.selected = items.includes(element.value);
        });
        originalOptions.forEach(function(element) {
            element.selected = items.includes(element.value);
        });

        component.set("v.options_", options);
        component.set('v.originalOptions', originalOptions);
    },

    clearSelectedItems: function(component) {
        var options = component.get("v.options_") || [];
        var originalOptions = component.get("v.originalOptions") || [];

        options.forEach(function(element) {
            element.selected = false;
        });
        originalOptions.forEach(function(element) {
            element.selected = false;
        });

        component.set("v.options_", options);
        component.set('v.originalOptions', originalOptions);

        this.dispatchSelectChangeEvent(component, []);
    },

    setInfoText: function(component, values) {
        if(values.length === 0) {
            component.set("v.infoText", $A.get("$Label.c.SelectAnOption"));
            component.set("v.searchHint", '');
        } else if(values.length === 1) {
            component.set("v.infoText", values[0]);
            component.set('v.searchHint', values[0]);
        }
        else if(values.length > 1 && $A.util.isArray(values)) {
            component.set("v.infoText", this.trunc(values.join(', ')));
        } else {
            component.set("v.infoText", values.replace(/;/g , ", "));
        }
    },

    trunc: function(str) {
        if(str.length > 25) {
            str = str.substring(0, 24) + "...";
        }
        return str;
    },

    getSelectedValues: function(component){
        var options = component.get("v.originalOptions");
        var values = [];
        options.forEach(function(element) {
            if (element.selected) {
                values.push(element.value);
            }
        });
        return values;
    },

    getSelectedLabels: function(component){
        var options = component.get("v.originalOptions") || [];
        var labels = [];
        options.forEach(function(element) {
            if (element.selected) {
                labels.push(element.label);
            }
        });
        return labels;
    },

    dispatchSelectChangeEvent: function(component, values) {
        var newValue      = values.join(';') || '';
        var selectedItems = component.get('v.selectedItems') || '';

        if (selectedItems !== newValue) {
            component.set('v.selectedItems', newValue);

            var compEvent = component.getEvent("selectChange");
            compEvent.setParams({ "values": values });
            compEvent.fire();
        }
    },

    cloneOptions: function(options) {
        var clonedOptions = [];
        this.deepClone(options, clonedOptions);
        return clonedOptions;
    },

    setFixedDropdownPosition: function (component) {
        var mainDiv = component.find('main-div');
        var dropdown = component.find('dropdown').getElement();
        var coords = mainDiv.getElement().getBoundingClientRect();
        var left = coords.left;
        var top = coords.bottom;

        dropdown.style.position = 'fixed';
        dropdown.style.top = top + 'px';
        dropdown.style.left = left + 'px';
        dropdown.style.width = mainDiv.getElement().offsetWidth + 'px';
        dropdown.style.maxWidth = mainDiv.getElement().offsetWidth + 'px';

        var dropdownHeight = this.getHeightOfNonVisibleElement(dropdown);
        var utilityBarHeight = 45;
        var dropdownNeededHeight = top + dropdownHeight + utilityBarHeight;
        if(dropdownNeededHeight > window.innerHeight){
            dropdown.style.top = window.innerHeight - dropdownHeight - utilityBarHeight + 'px';
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

    filterOptions: function(component, term) {
        var searchTerm      = $A.util.isUndefinedOrNull(term) ? component.get('v.searchTerm') : term;
        var originalOptions = component.get('v.originalOptions');

        var options = originalOptions.filter(function (option) {
            return option.label.toLowerCase().startsWith(searchTerm.toLowerCase());
        });

        component.set('v.options_', options);

        if (!!searchTerm && options.length > 0) {
            var hint = options[0].label.replace(options[0].label.substr(0, searchTerm.length), searchTerm);
            component.set('v.searchHint', hint);
        } else {
            component.set('v.searchHint', '');
        }
    },

    selectElement: function(component, options, value, selected) {
        var isMultipleAllowed = component.get('v.multiple');

        options.forEach(function(element) {
            if (element.value === value) {
                element.selected = selected !== "true";
            } else if (!isMultipleAllowed) {
                element.selected = false;
            }
        });
    },

    handleSelection: function(component, value, selected, closeDropdown) {
        var options           = component.get("v.options_");
        var originalOptions   = component.get('v.originalOptions');

        this.selectElement(component, options, value, selected);
        this.selectElement(component, originalOptions, value, selected);

        if (!component.get('v.multiple') && closeDropdown) {
            this.closeDropdown(component);
        }

        component.set("v.options_", options);
        component.set("v.originalOptions", originalOptions);

        var values = this.getSelectedValues(component);
        var labels = this.getSelectedLabels(component);

        this.setInfoText(component, labels);
        this.dispatchSelectChangeEvent(component, values);
    },

    navigate: function(component, index, menuOption) {
        component.set('v.focusedOptionIndex', index);

        var options = component.get('v.options_');
        component.set('v.searchTerm', options[index].label);
        component.set('v.searchHint', options[index].label);

        this.setInfoText(component, [options[index].label]);

        component.set('v.isFocusing', true);
        if (!$A.util.isUndefinedOrNull(menuOption)) {
            setTimeout($A.getCallback(function() {
                menuOption.querySelector('a').focus();
                component.set('v.isFocusing', false);
            }));
        }
    },

    focusOnInput: function(component) {
        var picklistInput = component.find('picklistInput');
        picklistInput.getElement().focus();
    },

    getMenuOptions: function(component) {
        var menu = component.find('menu');
        return menu.getElement().children;
    },

    clearSearchAndCloseNavigation: function(component) {
        component.set('v.searchTerm', component.get('v.searchTermBeforeNavigation'));
        component.set('v.searchTermBeforeNavigation', '');
        component.set('v.searchHint', '');
        component.set('v.optionsNavigation', false);
        component.find('menu').getElement().scrollTop = 0;
    },

    openDropdown: function(component) {
        var mainDiv = component.find('main-div');
        $A.util.addClass(mainDiv, 'slds-is-open');
    },

    closeDropdown: function(component) {
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
    },

    isDifferentOptionSearched: function(component) {
        var selectedLabel = this.findSelectedLabel(component);
        
        return selectedLabel !== component.get('v.searchTerm');
    },

    isFirstOptionNotSelected: function(options) {
        return options.length > 0 && !options[0].selected;
    },

    isAnyItemSelected: function(component) {
        return component.get('v.selectedItems');
    },

    isSearchTermNotEmpty: function(component) {
        return !!component.get('v.searchTerm');
    },

    shouldTriggerTabAction: function(component, options) {
        return this.isDifferentOptionSearched(component) &&
            (!this.isAnyItemSelected(component) || this.isSearchTermNotEmpty(component)) &&
            this.isFirstOptionNotSelected(options);
    },

    clearSearch: function(component) {
        this.clearSelectedItems(component);
        this.filterOptions(component);
        this.setInfoText(component, []);
    },

    validate: function(component) {
        var isValid = true;

        if (component.get('v.required') && $A.util.isEmpty(component.get('v.selectedItems'))) {
            isValid = false;
        }

        component.set('v.isValid', isValid);
        return isValid;
    },

    findSelectedOption: function(component) {
        var originalOptions = component.get('v.originalOptions');
        var selectedOption = originalOptions.find(function (option) {
            return option.value === component.get('v.selectedItems');
        });

        return selectedOption;
    },

    findSelectedLabel: function(component) {
        var selectedOption = this.findSelectedOption(component);
        return selectedOption ? selectedOption.label : '';
    }
})