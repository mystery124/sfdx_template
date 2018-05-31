({
    onOpenChange : function(component, event, helper) {
        if (component.get('v.isOpen')) {
            if(component.get('v.nubbinPositionClass').indexOf('slds-nubbin_left-bottom') !== -1) {
                helper.leftBottomPosition(component);
            } else if(component.get('v.nubbinPositionClass').indexOf('slds-nubbin_left') !== -1) {
                helper.leftPosition(component);
            } else {
                helper.defaultPosition(component);
            }
        } else {
            setTimeout(function(){
                if (!component.get('v.isOpen')) {
                    var popover = component.find('popoverContainer');
                    if(popover) {
                        popover.getElement().style.left = window.frames.screen.width + 'px';
                    }
                }
            }, 100);
        }
    },

    handleDialogClose: function(component) {
        component.set('v.isOpen', false);
    },

    handleDialogOpen: function(component) {
        component.set('v.isOpen', true);
    },
})