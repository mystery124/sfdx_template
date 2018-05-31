({
    defaultPosition: function(component) {
        var popoverElement     = this.getPopoverElement(component);
        var popoverHeightWidth = this.getPopoverClientHeightWidth(component);

        var parentTop  = component.get('v.parentTop');
        var parentLeft = component.get('v.parentLeft');
        var top        = parentTop - popoverHeightWidth.clientHeight / 2;
        var left       = parentLeft - popoverHeightWidth.clientWidth - 10;

        top = this.getTopPosition(top, window.innerHeight, popoverHeightWidth.clientHeight);

        popoverElement.style.top  = top + 'px';
        popoverElement.style.left = left + 'px';
    },

    leftPosition: function(component) {
        var popoverElement     = this.getPopoverElement(component);
        var popoverHeightWidth = this.getPopoverClientHeightWidth(component);

        var parentTop   = component.get('v.parentTop');
        var parentRight = component.get('v.parentRight');
        var top         = parentTop - popoverHeightWidth.clientHeight / 2;
        var left        = parentRight + 10;

        top = this.getTopPosition(top, window.innerHeight, popoverHeightWidth.clientHeight);

        popoverElement.style.top  = top + 'px';
        popoverElement.style.left = left + 'px';
    },

    leftBottomPosition: function(component) {
        var popoverElement     = this.getPopoverElement(component);
        var popoverHeightWidth = this.getPopoverClientHeightWidth(component);

        var parentTop   = component.get('v.parentTop');
        var parentRight = component.get('v.parentRight');
        var top         = parentTop - popoverHeightWidth.clientHeight + window.screenTop - 200;

        popoverElement.style.top  = top + 'px';
        popoverElement.style.left = parentRight + 'px';
    },

    getPopoverClientHeightWidth: function(component) {
        var popoverElement = this.getPopoverElement(component);

        return {
            clientHeight: popoverElement.clientHeight,
            clientWidth: popoverElement.clientWidth
        };
    },

    getPopoverElement: function(component) {
        var popover = component.find('popoverContainer');
        return popover.getElement();
    },

    getTopPosition: function(top, innerHeight, clientHeight) {
        var headerHeight = 90;
        var footerHeight = 45;

        if(top < headerHeight) {
            return headerHeight;
        } else if(top > innerHeight - clientHeight - footerHeight) {
            return innerHeight - clientHeight - footerHeight;
        } else {
            return top;
        }
    }
})