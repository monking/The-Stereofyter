function pop(content, width, height) {
	var id = 'pop'+$('.pop').length;
	var dialog = $('<div class="pop" id="'+id+'"/>')
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
	sizePop(dialog, width, height);
	container.hide().slideDown(300);
	return dialog;
}

function sizePop(selector, width, height) {
	var dialog = $(selector);
	if (!dialog) return;
	var css = {};
	css.width = width? width+'px': 'auto';
	css.height = height? height+'px': 'auto';
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