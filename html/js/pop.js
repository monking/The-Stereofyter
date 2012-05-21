function Pop(options) {
    this.options = $.extend({
        content: '',
        width: 'auto',
        height: 'auto',
        open: null,
        close: null
    }, options);
    this.init();
}

Pop.prototype = {
    list: {},
    init: function() {
        var $this = this;
        $this.id = 'pop'+$('.pop').length;
        Pop.list[$this.id] = $this;
        $this.dialog = $('<div class="pop-dialog" id="'+$this.id+'"/>')
        $this.dialog.data("pop", $this);
        var $container = $('<div class="container"/>').appendTo($this.dialog);
        var contentBox = $('<div class="content"/>').appendTo($container);
        $this.contentObject = $($this.options.content);
        if (!$this.contentObject.length)
            $this.contentObject = $this.options.content;
        var parent = $this.contentObject.parent();
        if (parent.length) $this.popHome = parent;
        contentBox.append($this.contentObject);
        var closeButton = $('<div class="close"></div>').appendTo($this.dialog);
        closeButton.click(function() {
            $this.closePop();
        });
        $('body').append($this.dialog);
        $this.sizePop();
        $container.hide().slideDown(300);
        if (typeof $this.options.open == "function")
            $this.options.open.call($this.dialog);
    },
    sizePop: function(width, height) {
        var $this = this;
        if (!isNaN(width)) $this.options.width = width;
        if (!isNaN(height)) $this.options.height = height;
        if (!$this.dialog) return;
        var css = {};
        css.width = $this.options.width + (!isNaN($this.options.width)? 'px': '');
        css.height = $this.options.height + (!isNaN($this.options.height)? 'px': '');
        var content = $('.content', $this.dialog);
        content.css(css);
        var windowHeight = $(window).height() - 80;
        var windowWidth = $(window).width() - 50;
        if (content.height() > windowHeight)
            content.height(windowHeight);
        if (content.width() > windowWidth)
            content.width(windowWidth);
        $this.positionPop();
    },
    positionPop: function() {
        var $this = this;
        var css = {};
        css.left = Math.round($(window).width() / 2 - $this.dialog.width() / 2)+'px';
        //css.top = Math.round($(window).height() / 2 - $this.dialog.height() / 2)+'px';
        $this.dialog.css(css);
    },
    closePop: function() {
        var $this = this;
        if (!$this.dialog.length) return;
        $('.container', $this.dialog).slideUp(function() {
            if ($this.popHome)
                $this.popHome.append($this.contentObject);
            else
                $this.dialog.remove();
            delete Pop.list[$this.id];
            if (typeof $this.options.close == "function")
                $this.options.close.call($this.dialog);
        });
    }
}

$(window).resize(function(event) {
	$(Pop.list).each(function() {
		this.positionPop();
	});
});
