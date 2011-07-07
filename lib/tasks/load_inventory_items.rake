namespace :items do
  desc 'Loads the inventory items for outreach activity'
  task :load_all => :environment do
    item_list = [
        "Bags", 
        "Bibs",
        "Coloring Books",
        "Frisbees",
        "Hats",
        "Magnets",
        "Other",
        "Pencils",
        "Pens",
        "Screw Drivers",
        "Sticky Notes",
        "T-shirts",
        "Wallets",
        "Water Bottles" ]
    InventoryItem.delete_all
    item_list.each do |i|
      unless InventoryItem.find(:first, :conditions => {:name => i})
        InventoryItem.create(:name => i)
      end
    end
  end
end