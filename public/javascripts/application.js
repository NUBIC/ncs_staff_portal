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

function wire_up_select_other_class(select_class, other_class){
  $(select_class).each(function(){ 
    check_select_for_other_class($(this), $(this).siblings(other_class));
  });
  $(select_class).each(function(){ 
	$(this).change(function(){
	    check_select_for_other_class($(this), $(this).siblings(other_class));
	});
  });
}

function check_select_for_other_class(select_elt, other_elt){
  var s = select_elt;
  var o = other_elt

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

