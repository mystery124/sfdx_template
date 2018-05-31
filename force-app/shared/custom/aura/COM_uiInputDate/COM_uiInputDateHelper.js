({
    isValidFormat: function(component, value) {
        var isValid = true;
        var selectedDate = this.formatStringToDate(value);
        if( ! $A.util.isEmpty(value) && ! this.isDate(selectedDate)){
            isValid = false;
            component.set('v.error', $A.get('$Label.c.InvalidDateFormat'));
        }

        component.set('v.validity.valid', isValid);
        return isValid;
    },

    validateMaxDate: function(component, value) {
        var error;
        var isValid = true;
        var selectedDate = this.formatStringToDate(value);

        if(selectedDate > component.get('v.maxDate')){
            error = component.get('v.messageWhenMaxDateError');
            isValid = false;
        }

        component.set('v.error', error);
        component.set('v.validity.valid', isValid);

        return isValid;
    },

    validateMinDate: function(component, value) {
        var error;
        var isValid      = true;
        var selectedDate = this.formatStringToDate(value);

        if (selectedDate < component.get('v.minDate')) {
            error   = component.get('v.messageWhenMinDateError');
            isValid = component.get('v.minDateValidationType') === 'warning';
        }

        component.set('v.error', error);
        component.set('v.validity.valid', isValid);

        return isValid;
    },

    formatStringToDate: function(value) {
        var date = String(value).split('-');
        if(date.length === 3){
            return new Date(parseInt(date[0]), parseInt(date[1]) - 1, parseInt(date[2]));
        }
    },

    isDate: function (date) {
        var time = (date instanceof Date) ? date : (new Date(date));
        return !isNaN(time.valueOf());
    }
})