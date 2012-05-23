function registerExists() {
    $('#tracker a, .form-actions a').click(function(event) {
        var href = $(this).attr('href');
        saveStep(href);
        return false; // don't follow link
    });
}

function initStep() {
    $('#createUser').click(function(event) {
        var btn = $(this),
        admin_user = $('#admin_user'),
        admin_user_control = admin_user.closest('.control-group'),
        admin_password = $('#admin_password'),
        admin_password_control = admin_password.closest('.control-group'),
        admin_password2 = $('#admin_password2'),
        admin_password2_control = admin_password2.closest('.control-group'),
        valid = true;

        if (btn.hasClass('disabled')) return false;

        if (admin_user.val().trim().length == 0) {
            admin_user_control.addClass('error');
            valid = false;
        }
        else {
            admin_user_control.removeClass('error');
        }
        if (admin_password.val().trim().length == 0 || admin_password.val() != admin_password2.val()) {
            admin_password_control.addClass('error');
            admin_password2_control.addClass('error');
            valid = false;
        }
        else {
            admin_password_control.removeClass('error');
            admin_password2_control.removeClass('error');
        }

        if (valid) {
            $.ajax({
                type: 'POST',
                url: btn.attr('href'),
                data: { admin_user: admin_user.val(), admin_password: admin_password.val() }
            }).done(function(data) {
                btn.addClass('disabled');
                admin_user.add(admin_password).add(admin_password2).attr('disabled', '');
                resetAlert(admin_user_control.closest('form'));
                showSuccess(admin_user_control, data.status_msg);
            }).fail(function(jqXHR) {
                var obj = $.parseJSON(jqXHR.responseText);
                showError(admin_user_control, obj.status_msg);
            });
        }

        return false;
    });
}

function saveStep(href) {
    $.ajax({
        type: 'POST',
        url: window.location.pathname,
        data: {admin_user: $('#admin_user').val(),
               admin_password: $('#admin_password').val()}
    }).done (function(data) {
        window.location.href = href;
    }).fail(function(jqXHR) {
        var obj = $.parseJSON(jqXHR.responseText);
        showError($('form'), obj.status_msg);
        $("body").animate({scrollTop:0}, 'fast');
    });

   return false;
}