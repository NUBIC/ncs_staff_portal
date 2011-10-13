NCSPortal.SupervisorEmployees.UI = function (config) {
  var setupSupervisorEmployeesAutocompleter = function () {
      $(".supervisor_employees_combobox_autocompleter").combobox({watermark:'staff'});
   },
  supervisorEmployeesNestedAttributesForm = new NestedAttributes({
      container: $('.supervisor_employees'),
      association: 'supervisor_employees',
      content: config.supervisorEmployeesTemplate,
      addHandler: setupSupervisorEmployeesAutocompleter,
      caller: this
   });
   setupSupervisorEmployeesAutocompleter();
};