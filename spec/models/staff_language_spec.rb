require 'spec_helper'

describe StaffLanguage do
  it { should belong_to(:lang) }
  it { should validate_presence_of(:lang) }
end
