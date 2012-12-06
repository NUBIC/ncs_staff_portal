// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

NCSPortal = {};
NCSPortal.StaffLanguages = {};
NestedAttributes = {};
NCSPortal.ManagementTasks = {};
NCSPortal.OutreachStaffMembers = {};
NCSPortal.OutreachRaces = {};
NCSPortal.OutreachTargets = {};
NCSPortal.OutreachEvaluations = {};
NCSPortal.OutreachSegments = {};
NCSPortal.OutreachItems = {};
NCSPortal.OutreachLanguages = {};
NCSPortal.SupervisorEmployees = {};

// Added X-CSRF-Token to request header as per http://weblog.rubyonrails.org/2011/2/8/csrf-protection-bypass-in-ruby-on-rails
$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

// Used inside document ready method call to wire up selects with other fields
function wire_up_select_other(select_id, other_id){
  check_select_for_other(select_id, other_id);
  // Check on item change
  $(select_id).change(function(){
    check_select_for_other(select_id, other_id);
  });
}

// Used to enable/disable 'other' input type text field
function check_select_for_other(select_id, other_id){
  var s = $(select_id+" option:selected");
  var o = $(other_id);

  // making sure the object id's given above exist on page
  if((o.size() > 0) && (s.size() > 0)){
    // 'Other' = -5
    if(s.val() == "-5"){
        o.removeAttr('disabled');
        o.css('background-color', '#EEF1C3'); //to make the change more visible
    }
    else{
        o.val(''); //clear the other field
        o.attr('disabled', 'disabled');
        o.css('background-color', '#d0d0d0'); // to make disabled more visible
    }
  }
}

function wire_up_select_yes_selector(select_id, yes_class, disabled_class){
  check_select_for_yes_selector(select_id, yes_class, disabled_class);
  // Check on item change
  $(select_id).change(function(){
    check_select_for_yes_selector(select_id, yes_class, disabled_class);
  });
}

// Used to enable/disable 'other' input type text field
function check_select_for_yes_selector(select_id, yes_class, disabled_class){
  var s = $(select_id+" option:selected");

    // 'Yes' = 1
    if(s.val() == "1" || s.val() == "Yes") {
	    $(yes_class).each(function(){
	      $(this).removeAttr('disabled');
	    })
    }
    else{
      $(yes_class).each(function(){
        if ($(this).val()) {
          $(this).removeAttr('disabled');
        } else {
          $(this).val('');
          $(this).attr('disabled', 'disabled');
        }
	    })

	    $(disabled_class).each(function(){
        if ($(this).val()) {
          $(this).removeAttr('disabled');
        }
        else {
          $(this).val('');
          $(this).attr('disabled', 'disabled');

          if ($(this).get(0).tagName == "INPUT") {
            $(this).css('background-color', '#d0d0d0');
          }
          if ($(this).get(0).tagName == "A" || $(this).get(0).tagName == "TR") {
            $(this).hide();
          }
        }
	    })
    }
}

function wire_up_select_other_class(select_class, other_class, other_label_class){
  $(select_class).each(function(){
    check_select_for_other_class($(this), $(this).siblings(other_class), other_label_class);
  });
  $(select_class).each(function(){
	  $(this).change(function(){
	    check_select_for_other_class($(this), $(this).siblings(other_class), other_label_class);
	  });
  });
}

function check_select_for_other_class(select_elt, other_elt, other_label_class){
  var s = select_elt;
  var o = other_elt

  if((o.size() > 0) && (s.size() > 0)){
    // 'Other' = -5
    if(s.val() == "-5" || s.val() == "Other"){
	    o.siblings(other_label_class).show();
	    o.show()
      o.css('background-color', '#EEF1C3'); //to make the change more visible
    }
    else{
      o.val(''); //clear the other field
      o.siblings(other_label_class).hide();
	    o.hide()
    }
  }
}

function wire_up_yes_enable_radio(select_id, other_class){
  check_select_for_yes(select_id, other_class);

  $(select_id).change(function(){
    check_select_for_yes(select_id, other_class);
  });
}

function check_select_for_yes(select_id, other_class){
  var s = $(select_id+" option:selected");
  var o = $(other_class);
  if((o.size() > 0) && (s.size() > 0)){
    // 'Yes' = 1
    if(s.val() == "1"){
        o.removeAttr('disabled');
        o.css('background-color', '#EEF1C3'); //to make the change more visible
    }
    else{
	    o.removeAttr('checked');
	    $("#cert_date_value").val('');
	    make_cert_date_input_disable()
        o.attr('disabled', 'disabled');
        o.css('background-color', '#d0d0d0'); // to make disabled more visible
    }
  }
}

function get_cert_date_value() {
  if ($('input:radio[name=cert_date]:checked').val() != 'date') {
    make_cert_date_input_disable();
  }
  $("#cert_date_temp").change(function(){
    $("#cert_date_value").val($("#cert_date_temp").val());
  });
  $("input:radio[name=cert_date]").click(function() {
    if ( $(this).val() == 'date' ) {
      make_cert_date_input_enable();
    } else {
      $("#cert_date_value").val($(this).val())
      make_cert_date_input_disable();
    }
  });
}

function make_cert_date_input_disable() {
  $("#cert_date_temp").attr('disabled', 'disabled');
  $("#cert_date_temp").css('background-color', '#d0d0d0')
  $("#cert_date_temp").val('')
}

function make_cert_date_input_enable() {
  $("#cert_date_temp").removeAttr('disabled');
  $("#cert_date_temp").css('background-color', '#EEF1C3')
}

function get_exp_date_value() {
  if ($('input:radio[name=exp_date]:checked').val() != 'date') {
    make_exp_date_input_disable();
    $("#exp_date_value").val('')
  }
  $("#exp_date_field").change(function(){
    $("#exp_date_value").val($("#exp_date_field").val());
  });
  $("input:radio[name=exp_date]").click(function() {
    if ( $(this).val() == 'date' ) {
      make_exp_date_input_enable();
    } else {
      $("#exp_date_value").val($(this).val())
      make_exp_date_input_disable();
    }
  });
}

function make_exp_date_input_disable() {
  $("#exp_date_field").attr('disabled', 'disabled');
  $("#exp_date_field").css('background-color', '#d0d0d0')
  $("#exp_date_field").val('')
}

function make_exp_date_input_enable() {
  $("#exp_date_field").removeAttr('disabled');
  $("#exp_date_field").css('background-color', '#EEF1C3')
}

function get_dob_value() {
  if ($('input:radio[name=dob]:checked').val() != 'date') {
    make_date_input_disable("#birth_date_field")
    $("#dob_value").val('')
  }
  $("#birth_date_field").change(function(){
    $("#dob_value").val($("#birth_date_field").val());
  });
  $("input:radio[name=dob]").click(function() {
    if ($(this).val() == 'date') {
      $("#age_group_value").val('')
      make_date_input_enable("#birth_date_field")
      $("#dob_value").val($("#birth_date_field").val())
    } else {
      $("#age_group_value").val($(this).val())
      make_date_input_disable("#birth_date_field")
      $("#dob_value").val('')
    }
  });
}

function make_date_input_enable(input_id) {
  $(input_id).removeAttr('disabled');
  $(input_id).css('background-color', '#FFFFFF')
}

function make_date_input_disable(input_id) {
  $(input_id).attr('disabled', 'disabled');
  $(input_id).css('background-color', '#d0d0d0')
  $(input_id).val('')
}

function disabled_selected_options(select_class, other_flag) {
  $(select_class).click(function(elt){
    var current_selector = $(this)
    var current_selector_id = "#" + current_selector.attr('id')
    var all_selected_options = $(select_class).map(function(i, s){return $(this).val()}).get()
    $(all_selected_options).each(function(){
      if (this != current_selector.val()) {
        $(current_selector_id +" option[value="+this+"]").attr('disabled', 'disabled')
      }
      if (other_flag == true) {
        $(current_selector_id +" option[value=-5]").removeAttr('disabled')
        $(current_selector_id +" option[value=Other]").removeAttr('disabled')
      }
    })
  });
}

function wire_up_select_yes_nested_attribute(select_id, nested_attribute_class) {
  check_select_for_yes_nested_attribute(select_id, nested_attribute_class);
  // Check on item change
  $(select_id).change(function(){
    check_select_for_yes_nested_attribute(select_id, nested_attribute_class);
  });
}

function check_select_for_yes_nested_attribute(select_id, nested_attribute_class) {
  var s = $(select_id+" option:selected");

  // 'Yes' = 1
  if(s.val() == "1" || s.val() == "Yes") {
    $(nested_attribute_class).each(function(){
      $(this).show();
    })
  } else{
    $(nested_attribute_class).each(function(){
      $(this).val('');
      $(this).hide();
    })
    var hidden_fields = nested_attribute_class + " :input[type=hidden]"
    $(hidden_fields).each(function() {
      $(this).val("1")
    })
  }
}

function wire_up_pay_amount(select_id, other_id){
  check_select_for_pay_amount(select_id, other_id);
  $(select_id).change(function(){
    check_select_for_pay_amount(select_id, other_id);
  });
}

function check_select_for_pay_amount(select_id, other_id){
  var s = $(select_id+" option:selected");
  var o = $(other_id);

  if((o.size() > 0) && (s.size() > 0)){
    if (s.val() == "Voluntary") {
      o.val('0.00');
      o.attr('disabled', 'disabled');
      o.css('background-color', '#d0d0d0');
    } else{
      o.removeAttr('disabled');
      o.css('background-color', '#FFFFFF')
    }
  }
}

$(document).ready(function(){
  $(".datepicker").attr('placeholder', 'YYYY-MM-DD');
  $(".week_datepicker").attr('placeholder', 'YYYY-MM-DD');
  $(".datepicker").datepicker( {
    dateFormat: 'yy-mm-dd',
    changeMonth: true,
    changeYear: true,
    yearRange: '1920:2020'
  } );

  $(".week_datepicker").datepicker(
  {
    dateFormat: 'yy-mm-dd',
    changeMonth: true,
    changeYear: true,
    yearRange: '1920:2020',
    beforeShowDay: function(date)
      {
        if ($(this).attr('week_start_day') == "monday") {
          return [(date.getDay() == 1), ""]
        } else {
          return [(date.getDay() == 0), ""]
        }
      }
  } );

  $('.help_text_link').click(function(event) {
    var help_text = $(this).next('.help_text').val();
    var title = $(this).next('.help_text').attr('title');
    $('<div id="dialog">' + help_text + '</div>').appendTo('body');
      event.preventDefault();
      $("#dialog").dialog({
        title: title,
        width: 600,
        modal: true,
        close: function(event, ui) {
          $("#dialog").remove();
        }
      });
  });
})
