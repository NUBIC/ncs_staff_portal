NCSPortal.StaffLanguages.UI = function (config) {
  staffLanguagesNestedAttributesForm = new NestedAttributes({
      container: $('.staff_languages'),
      association: 'staff_languages',
      content: config.staffLanguagesTemplate,
      caller: this
   });
};
