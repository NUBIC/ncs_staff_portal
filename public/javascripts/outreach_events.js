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
