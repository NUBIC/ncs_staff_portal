require 'fastercsv'
module MdesDataLoader

  def self.load_codes(l_file)
    puts "Loading MDES codes in #{Rails.env} database..."
    carry_row1, carry_row2 = ""
    FasterCSV.foreach(File.dirname(__FILE__) + '/' + l_file, :headers => true) do |row|
      # This is to handle the weird way they wrote out the rows and how they end up in csv
      unless row["Specific Code List Name"].nil?
        carry_row1 = row["Specific Code List Name"]
        carry_row2 = row["Code List Description"]
      end
      cd = {
        :list_name => carry_row1,
        :list_description => carry_row2,
        :local_code => Integer(row["Local Code"]),
        :global_code => row["Global Code Value"],
        :display_text => row["Code Text"],
      }
      clean_strings(cd)
      unless NcsCode.find(:first, :conditions => {:list_name => cd[:list_name], :local_code => cd[:local_code]})
        NcsCode.create!(cd)
      end
    end
    puts "Done!"
  end

  def self.clean_strings(doc)
    doc.each{ |k,v| doc[k] = clnr v if doc[k].is_a?(String) }
  end

  # Removing Windows/PC based chars that would otherwise break things
  def  self.clnr(str)
    unless str.nil?
      regx = [/\xD5/,/\x85/,/\xA0/,/\xD0/,/\xD2/,/\xCA/,/\xD3/]
      rt_str = str.strip
      regx.each do |r|
        rt_str.gsub!(r,'')
      end
      rt_str.gsub(/\x93/,'"').gsub(/\x94/,'"').gsub(/\x92/,'\'').gsub(/\x96/,'-')
    end
  end



end
