function alertAsync(msg) {
	setTimeout(function(){
		alert(msg);
	},0);
}

function login() {
	var form =$('form#pop_login').first().clone();
	var dialog = pop(form.show());
	form.submit(function(event) {
		event.preventDefault();
		$.ajax({
			url: '/scripts/login.php',
			data: form.serialize(),
			type: 'POST',
			dataType: 'json',
			success: function(data) {
				if (data.error) {
					alert(data.error);
				} else {
					$("#sfapp")[0].setUserSessionData(data);
					closePop(dialog);
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