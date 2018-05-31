({
    init: function(component, event, helper) {
        var options = component.get("v.options");

        if($A.util.isUndefinedOrNull(options)) {
            return;
        }

        var clonedOptions = helper.cloneOptions(options);
        var values = component.get('v.selectedItems');

        clonedOptions.sort(function compare(a,b) {
            if (a.value === 'All' || a.label < b.label){
                return -1;
            }
            
            if (a.label > b.label){
                return 1;
            }

            return 0;
        });

        component.set("v.options_", clonedOptions);
        component.set('v.originalOptions', clonedOptions);

        if($A.util.isUndefinedOrNull(values)) {
            return;
        }

        helper.markSelectedItems(component, values);
        var labels = helper.getSelectedLabels(component);
        helper.setInfoText(component, labels);
    },

    handleSelectedItemsChange: function(component, event, helper) {
        var value = component.get('v.selectedItems');

        if($A.util.isUndefinedOrNull(value)) {
            helper.setInfoText(component, []);
            helper.clearSelectedItems(component);
            return;
        }

        if(typeof value !== 'string') {
            return;
        }

        helper.markSelectedItems(component, value);
        var labels = helper.getSelectedLabels(component);
        helper.setInfoText(component, labels);

        component.set('v.searchTerm', labels.join(', '));
        helper.validate(component);
    },

    handleClick: function(component, event, helper) {
        var mainDiv = component.find('main-div');

        if (component.get('v.autocomplete')) {
            helper.openDropdown(component);
            helper.focusOnInput(component);
            helper.filterOptions(component, '');
        } else {
            $A.util.toggleClass(mainDiv, 'slds-is-open');
        }

        helper.setFixedDropdownPosition(component);
    },

    handleSelection: function(component, event, helper) {
        var item = event.currentTarget;

        if (item && item.dataset) {
            var value = item.dataset.value;
            var selected = item.dataset.selected;

            var selectedItems = component.get('v.selectedItems');
            var autocomplete  = component.get('v.autocomplete');

            if (!autocomplete || (autocomplete && value !== selectedItems)) {
                helper.handleSelection(component, value, selected, true);
            } else {
                helper.closeDropdown(component);
            }
        }
    },

    handleMouseLeave: function(component, event) {
        component.set("v.dropdownOver", false);
    },

    handleMouseEnter: function(component, event) {
        component.set("v.dropdownOver", true);
    },

    handleOnBlur: function(component, event, helper) {
        if (!component.get("v.dropdownOver") && !component.get('v.optionsNavigation')) {
            helper.closeDropdown(component);
        }
    },

    validate: function(component, event, helper) {
        return helper.validate(component);
    },

    clearErrorMessage: function(component, event, helper) {
        component.set('v.isValid', true);
    },

    filterOptions: function(component, event, helper) {
        component.set('v.searchTerm', event.currentTarget.value);
        helper.filterOptions(component);

        if (!event.currentTarget.value) {
            helper.clearSearch(component);
        }
    },

    handleKeyDown: function(component, event, helper) {
        var arrowDown = ['ArrowDown', 'Down'];
        var arrowUp   = ['ArrowUp', 'Up'];

        if (event.key === 'Tab') {
            if (event.shiftKey) {
                helper.closeDropdown(component);
            } else {
                var options = component.get('v.options_');

                if (helper.shouldTriggerTabAction(component, options)) {
                    event.preventDefault();
                    var selectedItems = component.get('v.selectedItems');

                    if (selectedItems !== options[0].value) {
                        helper.handleSelection(component, options[0].value, "false", false);
                    } else {
                        component.set('v.searchHint', component.get('v.infoText'));
                    }
                }
            }
        } else if (arrowDown.indexOf(event.key) > -1 || arrowUp.indexOf(event.key) > -1) {
            event.preventDefault();
            component.set('v.optionsNavigation', true);
            component.set('v.searchTermBeforeNavigation', component.get('v.searchTerm'));

            var menuOptions = helper.getMenuOptions(component);
            var index       = arrowDown.indexOf(event.key) > -1 ? 0 : menuOptions.length - 1;

            if (menuOptions.length > 0) {
                helper.navigate(component, index, menuOptions[index]);
            }
        }
    },

    handleFocusOut: function(component, event, helper) {
        var options       = component.get('v.options_');
        var searchTerm    = component.get('v.searchTerm');
        var selectedItems = component.get('v.selectedItems');

        var selectedElement = options.find(function(element) {
            return element.label.toLowerCase() === searchTerm.toLowerCase();
        });
        var selectedElementExists = !$A.util.isUndefinedOrNull(selectedElement);

        if ((!searchTerm && !selectedItems) || (!selectedElementExists && options.length === 0)) {
            component.set('v.searchTerm', '');
            helper.clearSearch(component);
        } else {
            var value = selectedElementExists ? selectedElement.value : options[0].value;

            if (value !== selectedItems) {
                helper.handleSelection(component, value, "false", false);
            } else {
                var selectedLabel = helper.findSelectedLabel(component);
                component.set('v.searchTerm', selectedLabel);
                component.set('v.searchHint', selectedLabel);
            }
        }
    },

    handleFocus: function(component, event, helper) {
        helper.openDropdown(component);
        helper.setFixedDropdownPosition(component);
        helper.filterOptions(component);

        component.set('v.optionsNavigation', false);
    },

    navigate: function(component, event, helper) {
        if (component.get('v.autocomplete')) {
            var arrowDown = ['ArrowDown', 'Down'];
            var arrowUp   = ['ArrowUp', 'Up'];
            var currentIndex;

            if (arrowDown.indexOf(event.key) > -1 || arrowUp.indexOf(event.key) > -1) {
                event.preventDefault();
                currentIndex = component.get('v.focusedOptionIndex');
                
                if (arrowDown.indexOf(event.key) > -1) {
                    currentIndex++;
                } else {
                    currentIndex--;
                }
            }

            if (!$A.util.isUndefinedOrNull(currentIndex)) {
                var menuOptions = helper.getMenuOptions(component);

                if (currentIndex >= 0 && currentIndex <= menuOptions.length - 1) {
                    helper.navigate(component, currentIndex, menuOptions[currentIndex])
                } else {
                    helper.clearSearchAndCloseNavigation(component);
                    helper.setInfoText(component, []);
                    helper.focusOnInput(component);
                }
            }
        }
    },

    onDropdownFocusOut: function(component, event, helper) {
        if (component.get('v.autocomplete') && !component.get('v.isFocusing')) {
            helper.closeDropdown(component);
        }
    }
})