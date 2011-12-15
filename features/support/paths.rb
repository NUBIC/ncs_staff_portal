module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /login/
      dashboard_path

    when /the home\s?page/
      '/'

    when /the list of users/
      users_staff_index_path

    when /the default page/
      dashboard_path

    when /^a data collection task entry page for (\S+?)$/
      new_staff_data_collection_task_path(existing_staff($1))

    when /^a management task entry page for (\S+?)$/
      new_staff_management_task_path(existing_staff($1))

    when /^the staff information page for (\S+?)$/
      staff_path(existing_staff($1))
      
    when /the manage staff details page/
      staff_index_path

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end

  def existing_staff(username)
    Staff.find_by_username(username).tap { |s| s.should_not be_nil }
  end
  private :existing_staff
end

World(NavigationHelpers)
