// Forum jQuery Plugin
// Christopher Lovejoy, http://www.chrislovejoy.com 2012
(function($){
    $.fn.forum = function(options) {
        options = $.extend({
            limit: {
                glance: 3,
                preview: 10,
                detail: 100
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
        var list = [];
        var listXRef = {};
        var thread = [];
        var threadXRef = {};
        var fetch = function(threadId) {
            $.ajax({
                url: options.api,
                data: {
                    limit:options.limit[threadId ? "detail" : options.view],
                    thread:threadId ? threadId : ''
                },
                dataType: 'json',
                success: function(data) {
                    if (threadId) {
                        processThreadData(data);
                    } else {
                        processListData(data);
                    }
                }
            });
        }
        var processListData = function(data) {
            list = data;
            listXRef = {};
            for (var i = 0; i < list.length; i++) {
                listXRef[list[i].id] = i;
            }
            if (views[options.view].type == "list")
                show();
        }
        var processThreadData = function(data) {
            thread = data;
            threadXRef = {};
            for (var i = 0; i < thread.length; i++) {
                threadXRef[thread[i].id] = i;
            }
            show("detail");
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
                var markup = '<ul class="thread">';
                var currentDepth = 0;
                for (var i = 0; i < thread.length; i++) {
                    var post = thread[i];
                    var depthDiff = Math.abs(post.depth - currentDepth);
                    if (post.depth > currentDepth) {
                        for (var d = 0; d < depthDiff; d++) {
                            markup += '<ul class="thread'+(post.depth ? ' reply' : '')+'">';
                        }
                    } else if (post.depth < currentDepth) {
                        for (var d = 0; d < depthDiff; d++) {
                            markup += '</ul>';
                        }
                    }
                    currentDepth = post.depth;
                    markup += '<li class="post" ref="'+post.id+'">';
                    var title = post.link_name || post.title || 'New Post';
                    $(".title", $detailContainer).text(title);
                    var replyLink = '';
                    markup += '<div class="byline"><span class="user">'+post.username+'</span>'
                        +'<a href="#" class="reply button">Reply</a>'
                        +'</div>';
                    if (post.link)
                        markup += '<div class="link"><a href="'+post.link+'" ref="'+post.link_id+'">Load Mix: '+post.link_name+'</a></div>';
                    markup += '<div class="message">'+post.message+'</div>'
                        +'</li>';
                }
                markup += '</ul>';
                $(".body", $detailContainer).html(markup);

                var $replyForm = $("form.reply", $detailContainer);
                $(".link a", $detailContainer).click(function(event) {
                    if (!$("#sfapp")[0].loadMix) return;
                    event.preventDefault();
                    $("#sfapp")[0].loadMix(parseInt($(this).attr('ref')));
                });
                $("a.reply", $detailContainer).not(".disabled").click(function(event) {
                    event.preventDefault();
                    var $post = $(this).closest(".post")
                    var post = thread[threadXRef[$post.attr("ref")]];
                    if (post.depth >= 9) {
                        $post = $post.closest(".thread").prev(".post");
                    var post = thread[threadXRef[$post.attr("ref")]];
                    }
                    $(".replying-to", $detailContainer).removeClass("replying-to");
                    $post.addClass("replying-to");
                    $("input[name=reply_on]", $replyForm).val(post.id);
                    $replyForm.show();
                    $("[name=message]", $replyForm).val("").focus();
                });
                $replyForm.unbind("submit").submit(function(event) {
                    event.preventDefault();
                    $.ajax({
                        url: options.api,
                        type: "post",
                        dataType: "json",
                        data: $replyForm.serialize(),
                        success: function(json) {
                            if (json && json.status == "ok") {
                                $replyForm.hide();
                                $(".replying-to", $detailContainer).removeClass("replying-to");
                            } else if (json.message =="invalid user") {
                                login(function() {
                                    $replyForm.submit();
                                });
                            }
                        }
                    });
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
                paging.pages = Math.ceil(list.length / paging.limit);
                for (var i = paging.page * paging.limit; i < paging.offset + paging.limit && i < list.length; i++) {
                    var title = list[i].link_name || list[i].title || 'New Post';
                    var markup = '<li class="post" ref="'+list[i].id+'">';
                    markup += '<h4 class="title">'+title+'</h4>';
                    markup += '<div class="message">'+list[i].message+'<div class="tail-overlay"></div></div>';
                    markup += '</li>';
                    $list.append(markup);
                }
                paging.shown = i - paging.offset;
                $("li.post", $list).click(function(event) {
                    event.preventDefault();
                    fetch($(this).attr("ref"));
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
        fetch();
    };
})(jQuery);
