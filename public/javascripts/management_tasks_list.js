NCSPortal.ManagementTasks.UI = function (config) {
  managementTasksNestedAttributesForm = new NestedAttributes({
      container: $('.management_tasks'),
      association: 'management_tasks',
      content: config.managementTasksTemplate,
      caller: this
   });
};
