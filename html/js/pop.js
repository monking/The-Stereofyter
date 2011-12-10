function pop(content, options) {
  options = $.extend({
    width: 'auto',
    height: 'auto',
    open: null,
    close: null
  }, options);
	var id = 'pop'+$('.pop').length;
	var dialog = $('<div class="pop" id="'+id+'"/>')
	dialog.data('options', options);
	var container = $('<div class="container"/>').appendTo(dialog);
	var contentBox = $('<div class="content"/>').appendTo(container);
	var contentObject = $(content);
	if (!contentObject.length)
		contentObject = content;
	var parent = contentObject.parent();
	if (parent.length) contentObject.data('popHome', parent);
	contentBox.append(contentObject);
	var closeButton = $('<div class="close">&times;</div>').appendTo(dialog);
	closeButton.click(function() {
		closePop(dialog);
	});
	$('body').append(dialog);
	sizePop(dialog);
	container.hide().slideDown(300);
	return dialog;
}

function sizePop(selector, width, height) {
	var dialog = $(selector);
	var options = dialog.data('options');
	if (!isNaN(width)) options.width = width;
	if (!isNaN(height)) options.height = height;
	if (!dialog) return;
	var css = {};
	css.width = options.width + (!isNaN(options.width)? 'px': '');
	css.height = options.height + (!isNaN(options.height)? 'px': '');
	var content = $('.content', dialog);
	content.css(css);
	var windowHeight = $(window).height() - 80;
	var windowWidth = $(window).width() - 50;
	if (content.height() > windowHeight)
		content.height(windowHeight);
	if (content.width() > windowWidth)
		content.width(windowWidth);
	positionPop(dialog);
}

function positionPop(selector) {
	var dialog = $(selector);
	var css = {};
	css.left = Math.round($(window).width() / 2 - dialog.width() / 2)+'px';
	//css.top = Math.round($(window).height() / 2 - dialog.height() / 2)+'px';
	dialog.css(css);
}

function closePop(selector) {
	var dialog = $(selector);
	if (!dialog.length) return;
	$('.container', dialog).slideUp(function() {
		var popHome = dialog.data('popHome');
		if (popHome) popHome.append(dialog);
		else dialog.remove();
	});
}

$(window).resize(function(event) {
	$('.pop').each(function() {
		positionPop(this);
	});
});