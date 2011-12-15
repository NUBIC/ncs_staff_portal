class OtherEntryValidator < ActiveModel::Validator
  def validate(record)
    entry = record.send(options[:entry])
    other_entry  = record.send(options[:other_entry])
    
    if !entry.blank? && entry.display_text.match(/^\s*other\s*$/i)
      if other_entry.blank?
        record.errors[options[:other_entry]] = "can't be blank. Please enter any value for other #{options[:entry]}."
      end
    elsif other_entry.blank?
      record["#{options[:other_entry]}"] = nil
    end
  end
end