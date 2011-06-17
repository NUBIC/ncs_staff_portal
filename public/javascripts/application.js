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
NCSPortal.OutreachSsus = {};
NCSPortal.OutreachTsus = {};
NCSPortal.OutreachItems = {};

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
	      $(this).val('');
	      $(this).attr('disabled', 'disabled');
	    })
	    
	    $(disabled_class).each(function(){
	      $(this).val('');
	      $(this).attr('disabled', 'disabled');
	      if ($(this).get(0).tagName == "INPUT") {
	        $(this).css('background-color', '#d0d0d0');
	      }
	      if ($(this).get(0).tagName == "A" || $(this).get(0).tagName == "TR") {
	        $(this).hide();
	        //$(this).click(function(){ return false; })
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
  $("#cert_date_temp").change(function(){
    $("#cert_date_value").val($("#cert_date_temp").val());
  });
  $("input:radio[name=cert_date]").click(function() {
    if ( $(this).val() == 'date' ) {
      make_cert_date_input_enable();
    } else if ($(this).val() == '-2' ) {
      $("#cert_date_value").val('-2')
	  make_cert_date_input_disable();
    } else if ($(this).val() == '-7' ) {
      $("#cert_date_value").val('-7')
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

function disabled_selected_options(select_class) {
  $(select_class).click(function(elt){
    var current_selector = $(this)
    var current_selector_id = "#" + current_selector.attr('id')
    var all_selected_options = $(select_class).map(function(i, s){return $(this).val()}).get()
    $(all_selected_options).each(function(){
      if (this != current_selector.val()) {
        $(current_selector_id +" option[value="+this+"]").attr('disabled', 'disabled')
      }
      $(current_selector_id +" option[value=-5]").removeAttr('disabled')
      $(current_selector_id +" option[value=Other]").removeAttr('disabled')
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
