NCSPortal.OutreachStaffMembers.UI = function (config) {
  var setupOutreachStaffAutocompleter = function () {
     // $(".outreach_staff_combobox_autocompleter").combobox({watermark:'an architect '});
   },
  outreachStaffMemberNestedAttributesForm = new NestedAttributes({
      container: $('.outreach_staff_members'),
      association: 'outreach_staff_members',
      content: config.outreachStaffMembersTemplate,
      addHandler: setupOutreachStaffAutocompleter,
      caller: this
   });
   setupOutreachStaffAutocompleter();
};

// NCSPortal.OutreachStaffMembers.UI = function (config) {
//   outreachStaffMemberNestedAttributesForm = new NestedAttributes({
//       container: $('.outreach_staff_members'),
//       association: 'outreach_staff_members',
//       content: config.outreachStaffMembersTemplate,
//       caller: this
//    });
// };