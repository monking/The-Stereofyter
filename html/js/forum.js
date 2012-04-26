// Forum jQuery Plugin
// Christopher Lovejoy, http://www.chrislovejoy.com 2012
(function($){
	$.fn.forum = function(options) {
		options = $.extend({
			limit: {
				glance: 3,
				preview: 10
			},
			maxLength: {
				glance: 32,
				preview: 1024
			},
			api: null,
			pollFreq: 60000,
			view: 'glance',
			lastView: 'glance',
			offset: 0
		}, options);
		var these = this;
		var story = [];
		var storyXRef = {};
		var fetch = function() {
			$.ajax({
				url:options.api,
				data:{limit:options.limit},
				dataType:'json',
				success:function(data) {
					processListData(data);
				}
			});
		}
		var processListData = function(data) {
			story = data;
			storyXRef = {};
			for (var i = 0; i < story.length; i++) {
				storyXRef[story[i].id] = i;
			}
			show();
		}
		var pollInterval;
		if (options.pollFreq) {
			pollInterval = setInterval(fetch, options.pollFreq);
		}
		var $container = $(this);
		var views = {
			detail: {
				container: $(".detail", $container),
				type: 'detail'
			},
			preview: {
				container: $(".preview", $container),
				type: 'list'
			},
			glance: {
				container: $(".glance", $container),
                type: 'list',
                before: function() {
                    options.offset = 0;
                }
			}
		};
		var draw = {
			detail: function() {
				$detailContainer = views[options.view].container;
                var title = story[options.offset].link_name || story[options.offset].title || 'New Post';
				$(".title", $detailContainer).text(title);
				var markup = "";
				if (story[options.offset].link)
					markup += '<div class="link"><a href="'+story[options.offset].link+'" ref="'+story[options.offset].link_id+'">Load Mix: '+story[options.offset].link_name+'</a></div>';
				markup += '<div class="message">'+story[options.offset].message+'</div>';
				$(".body", $detailContainer).html(markup);
				$(".link a", $detailContainer).click(function(event) {
					if (!$("#sfapp")[0].loadMix) return;
					event.preventDefault();
					$("#sfapp")[0].loadMix(parseInt($(this).attr('ref')));
				});
			},
			list: function() {
				var $listContainer = views[options.view].container;
				var $list = $("ul.list", $listContainer).empty();
				var paging = {
					offset: options.offset,
					limit: options.limit[options.view],
					page: 0,
					pages: 0,
					shown: 0
				};
				paging.page = Math.floor(paging.offset / paging.limit);
				paging.pages = Math.ceil(story.length / paging.limit);
				for (var i = paging.page * paging.limit; i < paging.offset + paging.limit && i < story.length; i++) {
                    var title = story[i].link_name || story[i].title || 'New Post';
					var markup = '<li class="entry" ref="'+story[i].id+'">';
					markup += '<h4 class="title">'+title+'</h4>';
					markup += '<div class="message">'+story[i].message+'<div class="tail-overlay"></div></div>';
					markup += '</li>';
					$list.append(markup);
				}
				paging.shown = i - paging.offset;
				$("li.entry", $list).click(function(event) {
					event.preventDefault();
					show("detail", storyXRef[parseInt($(this).attr("ref"))]);
				});
			}
		};
		var show = function(view, offset) {
			if (view && views.hasOwnProperty(view)) {
                if (views[view].hasOwnProperty("before"))
                    views[view].before.call(this);
				options.lastView = options.view;
				options.view = view;
				if (offset)
					options.offset = offset;
                else if (options.limit.hasOwnProperty(options.view))
                    options.offset -= options.offset % options.limit[options.view];
			}
			for (var key in views) {
				if (key == options.view) continue;
				views[key].container.hide();
			}
            console.log(options.offset);
			views[options.view].container.show();
			draw[views[options.view].type]();
		};
		$("a.set-view", $container).click(function(event) {
			event.preventDefault();
			show($(this).attr("rel"));
		});
		$("a.back-view", $container).click(function(event) {
			event.preventDefault();
			show(options.lastView);
		});
		/*
		$(".message", reply).keydown(function(event) {
			if (event.keyCode != 8 && !event.ctrlKey && !event.altKey && !event.metaKey && $(this).text().length >= options.maxLength) {
				event.preventDefault();
			}
		}).keyup(function(event) {
			var $this = $(this);
			var text = $this.text();
			if (text.length > options.maxLength) {
				$this.text(text.substring(0, options.maxLength));
			}
		});
		*/
		fetch();
	};
})(jQuery);
