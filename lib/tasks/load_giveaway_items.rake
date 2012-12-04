require 'csv'
namespace :giveaway_items do
  desc 'Loads the inventory items for outreach activity'
  task :load_all, [:file] => [:environment] do |t, args|
    FILE = args[:file]
    raise "Please pass the path to csv file.e.g 'rake items:load_all[path_to_file]'" unless FILE
    InventoryItem.delete_all  # Removes any previous entries of items
    counter = 0
    CSV.foreach("#{FILE}", :headers => true) do |csv|
      unless InventoryItem.find(:first, :conditions => {:name => csv["NAME"]})
        InventoryItem.create(:name => csv["NAME"])
        counter += 1
      end
    end
    unless InventoryItem.find(:first, :conditions => {:name => "Other"})
      InventoryItem.create(:name => "Other")
      counter += 1
    end
    puts "#{counter} giveaway items are loaded"
  end
end
