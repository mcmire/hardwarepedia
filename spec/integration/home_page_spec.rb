require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

feature "The home page" do
  story <<-EOT
    Some story goes here
    And stuff and things
  EOT
  
  scenario "Visiting the home page" do
    visit "/"
  end
end