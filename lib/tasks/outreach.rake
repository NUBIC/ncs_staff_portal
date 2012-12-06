require 'csv'

namespace :outreach do
  desc "map outreach event with name by outreach_event_id from csv file."
  task :map_names, [:file] => [:environment] do |t, args|
    FILE = args[:file]
    raise "Please pass the path to file with csv extension.e.g 'rake outreach:map_names[path_to_file]'" unless FILE
    counter = 0
    CSV.foreach("#{FILE}", :headers => true) do |csv|
      if csv["OUTREACH_EVENT_ID"]
        outreach = OutreachEvent.find_by_outreach_event_id(csv["OUTREACH_EVENT_ID"])
        if outreach
          outreach.send("name=", csv["OUTREACH_EVENT_NAME"])
          outreach.save(:validate => false)
          counter += 1
        else
          raise "No outreach record found with the OUTREACH_EVENT_ID = #{csv["OUTREACH_EVENT_ID"]}. Please make sure OUTREACH_EVENT_ID is correct."
        end
      end
    end
    unless counter == 0
      if counter == 1
        puts "#{counter} outreach event is updated with name to the NCS Navigator Ops"
      elsif
        puts "#{counter} outreach events are updated with name to the NCS Navigator Ops"
      end
    end
  end
end
