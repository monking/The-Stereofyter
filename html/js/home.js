function alertAsync(msg) {
	setTimeout(function(){
		alert(msg);
	},0);
}

var loginPop;
function login() {
  if (loginPop) return;
	var form =$('form#pop_login').first().clone();
	loginPop = pop(form.show());
  $(".toggle-register", form).click(function(event) {
    event.preventDefault();
    form = $(this).closest("form");
    $("input[name=action]", form).val("register");
    form.removeClass("login").addClass("register");
  });
  $(".toggle-login", form).click(function(event) {
    event.preventDefault();
    form = $(this).closest("form");
    $("input[name=action]", form).val("login");
    $(this).closest("form").removeClass("register").addClass("login");
  });
	form.submit(function(event) {
		event.preventDefault();
		$.ajax({
			url: '/scripts/login.php',
			data: form.serialize(),
			type: 'POST',
			dataType: 'json',
			success: function(data) {
				if (data.error) {
				} else {
					$("#sfapp")[0].setUserSessionData(data);
					closePop(loginPop);
					loginPop = null;
				}
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

$(function() {
	if (window.location.hash == '#login') {
		login();
		window.location.hash = '';
	}
});