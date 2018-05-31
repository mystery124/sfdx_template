({
    onOpenChange : function(component) {
        if (component.get('v.isOpen')) {
            var popover       = component.find('popoverContainer');
            var popoverHeight = popover.getElement().clientHeight;
            var parentTop     = component.get('v.parentTop');
            var parentLeft    = component.get('v.parentLeft');
            var top = parentTop - popoverHeight - 10;
            popover.getElement().style.top  = top + 'px';
            popover.getElement().style.left = parentLeft + 'px';
        }
    },

    handleDialogClose: function(component) {
        component.set('v.isOpen', false);
    },
})