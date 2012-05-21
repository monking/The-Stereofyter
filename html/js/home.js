function alertAsync(msg) {
	setTimeout(function(){
		alert(msg);
	},0);
}

var loginPop;
function login(callback) {
  if (loginPop) return;
	var form =$('form#pop_login').first().clone();
    loginPop = new Pop({
        content: form.show(),
        close: function() {
            loginPop = null;
        }
    });
  $(".toggle-register", form).unbind('click').click(function(event) {
    event.preventDefault();
    form = $(this).closest("form");
    $("input[name=action]", form).val("register");
    form.removeClass("login").addClass("register");
  });
  $(".toggle-login", form).unbind('click').click(function(event) {
    event.preventDefault();
    form = $(this).closest("form");
    $("input[name=action]", form).val("login");
    form.removeClass("register").addClass("login");
  });
	form.submit(function(event) {
		event.preventDefault();
		$.ajax({
			url: form.attr("action"),
			data: form.serialize(),
			type: 'POST',
			dataType: 'json',
			success: function(data) {
				if (data.error) {
				  alert(data.error);
				} else {
					$("#sfapp")[0].setUserSessionData(data);
					loginPop.closePop();
                    if (typeof callback == "function")
                        callback();
				}
			},
			error: function(data) {
                alert("An error occured during login. Please try again");
			}
		});
	});
}

function logout() {
	$.ajax({
		url: '/scripts/logout.php',
		success: function(data) {
			if (data != '') {
				alert(data);
			} else {
				$("#sfapp")[0].setUserSessionData(null);
			}
		}
	});
}

function help() {
	new Pop({content:$("#instructions").clone().show()});
}

$(function() {
  $("#forum").forum({
    api:'/scripts/forum.php'
  });
	if (window.location.hash == '#login') {
		login();
		window.location.hash = '';
	}
});
