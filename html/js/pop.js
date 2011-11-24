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
	contentBox.append(contentObject);
	var closeButton = $('<div class="close">&times;</div>').appendTo(dialog);
	closeButton.click(function() {
		closePop(dialog);
	});
	$('body').append(dialog);
	positionPop(dialog);
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
	console.log(css);
	$('.content', dialog).css(css);
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
	if (!dialog) return;
	$('.container', dialog).slideUp(function() {
		dialog.remove();
	});
}

$(window).resize(function(event) {
	$('.pop').each(function() {
		positionPop(this);
	});
});