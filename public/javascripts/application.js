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

