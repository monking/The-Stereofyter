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
            template: {
                glance: '',
                preview: '',
                detail: ''
            },
            api: null,
            pollFreq: 60000
        }, options);
        var these = this;
        var story = [];
        var fetch = function() {
            $.ajax({
                url:options.api,
                data:{limit:options.limit},
                dataType:'json',
                success:function(data) {
                    story = data;
                    $(these).each(function() {
                        $(this).data('forum').draw();
                    });
                }
            });
        }
        var pollInterval;
        if (options.pollFreq) {
            pollInterval = setInterval(fetch, options.pollFreq);
        }
        $(this).each(function() {
            var $container = $(this);
            var $full = $("div.full", $container),
                $preview = $("div.preview", $container),
                reply = $("form.reply", $container),
                showingFull = !options.preview;
            var toggleFull = function(show) {
                showingFull = typeof show != "undefined" ? show : !showingFull;
                $full.toggle(showingFull);
                $preview.toggle(!showingFull);
                draw();
            };
            var draw = function(options) {
                options = $.extend(
                    {
                        
                    },
                    options
                );
                var $list = $("ul.list", showingFull ? $full : $preview);
                $list.children().remove();
                var limit = showingFull ? options.limit : options.preview;
                for (var i = 0; i < limit && i < story.length; i++) {
                    var markup = '<li class="entry">';
                    markup += '<h4 class="title"><a href="#" ref="'+story[i].id+'">'+story[i].link_name+'</a></h4>';
                    markup += '<div class="message">'+story[i].message+'</div>';
                    markup += '</li>';
                    $list.append(markup);
                }
                $("li.entry .link a", list).click(function(e) {
                    $("#sfapp")[0].loadMix && e.preventDefault();
                    $("#sfapp")[0].loadMix(parseInt($(this).attr('ref')));
                });
            }
            $("a.toggle-full", container).click(function(event) {
                event.preventDefault();
                toggleFull();
            });
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
            container.data("forum", {
                draw:draw,
                fetch:fetch,
                toggleFull:toggleFull
            });
            console.log(container);
            toggleFull(showingFull);
        });
        fetch();
    };
})(jQuery);