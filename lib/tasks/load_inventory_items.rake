namespace :items do
  desc 'Loads the inventory items for outreach activity'
  task :load_all => :environment do
    item_list = [
        "Bags", 
        "Bibs",
        "Brochures",
        "Coloring Books",
        "Flyers",
        "Frisbees",
        "Hats",
        "Magnets",
        "Other",
        "Pencils",
        "Pens",
        "Posters",
        "Screw Drivers",
        "Sticky Notes",
        "T-shirts",
        "Wallets",
        "Water Bottles" ]
    item_list.each do |i|
      unless InventoryItem.find(:first, :conditions => {:name => i})
        InventoryItem.create(:name => i)
      end
    end
  end
end