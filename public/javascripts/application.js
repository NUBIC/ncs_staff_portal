// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

NCSPortal = {};
NCSPortal.StaffLanguages = {};
NestedAttributes = {};
NCSPortal.ManagementTasks = {};
NCSPortal.OutreachStaffMembers = {};

function check_for_destroy(element) {
	if (!$(element).attr('checked')) {
		$(element).siblings('.should_destroy').val(true);
	}
}

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
    if(s.val() == "-5"){
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
