// Forum jQuery Plugin
// Christopher Lovejoy, http://www.chrislovejoy.com 2012
(function($){
  $.fn.forum = function(options) {
    options = $.extend({
      preview: 3,
      limit: 10,
      previewLength: 32,
      api: null,
      poll: 60000,
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
    if (options.poll) {
      pollInterval = setInterval(fetch, options.poll);
    }
    $(this).each(function() {
      var container = $(this);
      var full = $("div.full", container),
        preview = $("div.preview", container),
        reply = $("form.reply", container),
        showingFull = !options.preview;
      var draw = function() {
        var list = $("ul.list", showingFull ? full : preview);
        list.children().remove();
        var limit = showingFull ? options.limit : options.preview;
        for (var i = 0; i < limit && i < story.length; i++) {
          var markup = '<li class="entry">';
          markup += '<div class="link"><a href="'+story[i].link+'" ref="'+story[i].link_id+'">'+story[i].link_name+'</a></div>';
          markup += '<div class="message">'+story[i].message+'</div>';
          markup += '</li>';
          list.append(markup);
        }
        $("li.entry .link a", list).click(function(e) {
          e.preventDefault();
          $("#sfapp")[0].loadMix(parseInt($(this).attr('ref')));
        });
      }
      container.data('forum', {
        draw:draw,
        fetch:fetch
      });
      (showingFull ? preview : full).hide();
    });
    fetch();
  };
})(jQuery);