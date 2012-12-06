Then /^the response contains the roles$/ do |table|
  json = JSON.parse(last_response.body)

  role_names = json['roles'].map { |r| r['name'] }.sort

  # This odd bit gets the role list into a form that can be used with
  # Cucumber's table diff.
  actual = role_names.map { |rn| [rn] }

  table.diff!(actual)
end
