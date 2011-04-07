require File.expand_path('../../spec_helper', __FILE__)

feature "Managing categories", <<-EOT do
  As an administrator
  I want to be able to create, update, and delete categories
EOT
  
  scenario "Listing categories (categories present)" do
    Factory(:category, :name => "Some Category")
    Factory(:category, :name => "Another Category")
    visit "/categories"
    tableish('#categories tr', 'th, td').should == [
      ['Name', '', '', ''],
      ['Some Category', 'Show', 'Edit', 'Delete'],
      ['Another Category', 'Show', 'Edit', 'Delete']
    ]
  end
  
  scenario "Listing categories (no categories present)" do
    visit "/categories"
    tableish('#categories tr', 'th, td').should == []
  end
  
  scenario "Adding a category" do
    visit "/categories/new"
    fill_in "Name", :with => "Some Category"
    press "Save"
    current_path.should == "/categories"
    body.should =~ /Category successfully added/
    tableish('#categories tr', 'th, td').should == [
      ['Name', '', '', ''],
      ['Some Category', 'Show', 'Edit', 'Delete']
    ]
  end
  
  scenario "Updating a category" do
    Factory(:category)
    visit "/categories"
    click "Edit"
    fill_in "Name", :with => "Another Category"
    press "Save"
    current_path.should == "/categories"
    body.should =~ /Category successfully updated/
    tableish('#categories tr', 'th, td').should == [
      ['Name', '', '', ''],
      ['Another Category', 'Show', 'Edit', 'Delete']
    ]
  end
  
  scenario "Deleting a category" do
    Factory(:category)
    visit "/categories"
    click "Delete"
    press "Yes, I'm sure"
    current_path.should == "/categories"
    body.should =~ /Category successfully deleted/
    tableish('#categories tr', 'th, td').should == []
  end
  
  javascript do
    scenario "Deleting a category" do
      Factory(:category)
      visit "/categories"
      browser.confirm(true) do
        click "Delete"
      end
      current_path.should == "/categories"
      body.should =~ /Category successfully deleted/
      tableish('#categories tr', 'th, td').should == []
    end
  end
  
end