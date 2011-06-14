NCSPortal.OutreachEvents.UI = function (config) {

  outreachRacesNestedAttributesForm = new NestedAttributes({
      container: $('.outreach_races'),
      association: 'outreach_races',
      content: config.outreachRacesTemplate,
      caller: this
   });
};

// NCSPortal.OutreachStaffMembers.UI = function (config) {
//   outreachStaffMemberNestedAttributesForm = new NestedAttributes({
//       container: $('.outreach_staff_members'),
//       association: 'outreach_staff_members',
//       content: config.outreachStaffMembersTemplate,
//       caller: this
//    });
// };