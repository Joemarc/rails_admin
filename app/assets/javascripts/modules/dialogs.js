aliada.dialogs.email_already_exists = function(email) {
  // Preload template
  var email_exists_template = _.template($('#email_already_exists_template').html());

  vex.open({
    content: email_exists_template({
      email: email
    }),
    showCloseButton: true,
    escapeButtonCloses: true,
    overlayClosesOnClick: true,
    contentClassName: 'email_already_exists',
    afterOpen: function() {
      $('#try-another-email-button').click(function() {
        var dialog = $(this).parents('.vex-content').data().vex;

        vex.close(dialog.id);

        $('#service_user_attributes_email').select();
      });
    }
  });
};

aliada.dialogs.postal_code_number_missing = function(postal_code_number) {
  // Preload template
  var postal_code_number_missing_template = _.template($('#postal_code_number_missing_template').html());

  vex.open({
    content: postal_code_number_missing_template({
      postal_code_number: postal_code_number
    }),
    showCloseButton: false,
    escapeButtonCloses: false,
    overlayClosesOnClick: false,
    contentClassName: 'postal_code_missing',
    afterOpen: function() {
      $('#try-another-postal-code-button').click(function() {
        var dialog = $(this).parents('.vex-content').data().vex;

        vex.close(dialog.id);

        $('#service_address_attributes_postal_code').select();
      })
    }
  });
};

aliada.dialogs.platform_error = function(error) {
  var platform_error_template = _.template($('#platform_error_template').html());
  log('platform_error ', error)

  vex.open({
    content: platform_error_template({
      error: error
    }),
    contentClassName: 'error',
  });
};

aliada.dialogs.conekta_error = function(error) {
  var conekta_error_template = _.template($('#conekta_error_template').html());

  vex.open({
    content: conekta_error_template({
      error: error
    }),
    contentClassName: 'error',
  });
};

aliada.dialogs.invalid_service = function(error) {
  var invalida_service_template = _.template($('#invalid_service_template').html());

  vex.open({
    content: invalida_service_template({
      error: error
    }),
    contentClassName: 'error',
  });
};

aliada.dialogs.succesfull_service_changes = function(next_path) {
  // Preload template
  var update_success_template = _.template($('#update_service_success_template').html());

  vex.open({
    content: update_success_template,
    showCloseButton: true,
    escapeButtonCloses: true,
    overlayClosesOnClick: true,
    contentClassName: 'update_success_dialog',
    afterOpen: function() {
      $('#try-another-email-button').click(function() {
        var dialog = $(this).parents('.vex-content').data().vex;

        vex.close(dialog.id);

        $('#service_user_attributes_email').select();
      });
    },
    afterClose: function() {
      redirect_to(next_path);
    }
  });
};

aliada.dialogs.confirm_service_cancel = function() {
  return new Promise(function(resolve,reject){
    vex.dialog.confirm({
      message: '¿Estás seguro que deseas cancelar tu servicio?',
      callback: function(value){
        if(value == true){
          resolve(value);
        }
      },
      buttons: [
        $.extend({}, vex.dialog.buttons.YES, {
          text: 'Si',
          className: 'action-button-gray size-extra-small vex-dialog-ok-button'
        }), $.extend({}, vex.dialog.buttons.NO, {
          text: 'No',
          className: 'action-button-pink size-extra-small vex-dialog-cancel-button',
        })
      ],
    });
    })
};
