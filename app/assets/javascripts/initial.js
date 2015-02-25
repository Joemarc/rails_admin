//= require base
//= require initial/_step_1_duration
//= require initial/_step_2_personal_info
//= require initial/_step_3_visit_info
//= require initial/_step_4_payment
//= require initial/_step_5_success

$(document).ready(function() {
  // KNOCKOUT initialization
  aliada.ko = {
    current_step: ko.observable(1),
    bedrooms: ko.observable(1),
    bathrooms: ko.observable(1),
    additional: ko.observable(1),
    forced_hours: ko.observable(null),
    extras_hours: ko.observable(0),
  }

  aliada.services.initial.step_1_duration(aliada, ko);
  aliada.services.initial.step_2_personal_info(aliada, ko);
  aliada.services.initial.step_3_visit_info(aliada, ko);
  aliada.services.initial.step_4_payment(aliada, ko);
  aliada.services.initial.step_5_success(aliada, ko);

  // Activates knockout.js
  ko.applyBindings(aliada.ko);

  // Handle next step
  $('#next_button').on('click',function(e){
      e.preventDefault();

      // Next if we are not on the last step
      var current_step = aliada.ko.current_step();
      var next_step = current_step === 5 ? current_step : current_step+1;

      aliada.ko.current_step(next_step);
  });
  
  // Handle next step
  $('#previous_button').on('click',function(e){
      e.preventDefault();

      // Next if we are not on the last step
      var current_step = aliada.ko.current_step();
      var previous_step = current_step === 1 ? current_step : current_step-1;

      aliada.ko.current_step(previous_step);
  });
});
