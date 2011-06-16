NCSPortal.OutreachRaces.UI = function (config) {
  outreachRacesNestedAttributesForm = new NestedAttributes({
      container: $('.outreach_races'),
      association: 'outreach_races',
      content: config.outreachRacesTemplate,
      caller: this
  });
};

NCSPortal.OutreachTargets.UI = function (config) {
  outreachTargetsNestedAttributesForm = new NestedAttributes({
      container: $('.outreach_targets'),
      association: 'outreach_targets',
      content: config.outreachTargetsTemplate,
      caller: this
  });
};

NCSPortal.OutreachEvaluations.UI = function (config) {
  outreachEvaluationsNestedAttributesForm = new NestedAttributes({
      container: $('.outreach_evaluations'),
      association: 'outreach_evaluations',
      content: config.outreachEvaluationsTemplate,
      caller: this
  });
};


NCSPortal.OutreachSsus.UI = function (config) {
  outreachSsusNestedAttributesForm = new NestedAttributes({
      container: $('.outreach_ssus'),
      association: 'outreach_ssus',
      content: config.outreachSsusTemplate,
      caller: this
  });
};

NCSPortal.OutreachStaffMembers.UI = function (config) {
  var setupOutreachStaffAutocompleter = function () {
      $(".outreach_staff_combobox_autocompleter").combobox({watermark:'staff'});
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

NCSPortal.OutreachItems.UI = function (config) {
  outreachItemsNestedAttributesForm = new NestedAttributes({
      container: $('.outreach_items'),
      association: 'outreach_items',
      content: config.outreachItemsTemplate,
      caller: this
  });
};