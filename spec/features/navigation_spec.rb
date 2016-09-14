require 'spec_helper'
# require 'byebug'
# require 'watir-webdriver'
# require 'capybara'


describe "Create place scenario" do
  context "Go to home page" do

    let(:browser) { @browser ||= Watir::Browser.new :firefox }   #for user interaction like clicking around and doing page navigation
    before { browser.goto "http://www.bigtent.com/log_in" }
    after { browser.close }

    it "opens homepage" do

      #LOGIN PAGE - CHECK STRUCTURE

      session = Capybara::Session.new :selenium # instantiate new session object (for inspecting it's layout)
      session.visit('http://www.bigtent.com/log_in')
      username = session.find(:xpath, "//form[@name='form_index_login']//li[@class='group']//input[@name='index_login[user_name]']")
      expect(username).to_not be_nil
      password = session.find(:xpath, "//form[@name='form_index_login']//li[@class='group']//input[@name='index_login[password]']")
      expect(password).to_not be_nil
      submit_btn = browser.a(:text => "Log in")
      expect(submit_btn).to_not be_nil

      #NAVIGATE TO LANDING PAGE

      browser.text_field(name: 'index_login[user_name]').set("fam@2d12.net")
      browser.text_field(name: 'index_login[password]').set("bigtent567")
      browser.a(:text => "Log in").click

      browser.div(id: 'recent_forum_topics').wait_until_present
      expect(browser.title).to eq("bigtent/group")

      session.has_field?('index_login_user_name') # => true
      session.fill_in('index_login_user_name', :with => 'fam@2d12.net')
      session.fill_in('index_login_password', :with => 'bigtent567')
      session.find_link('submit_button').click

      # LANDING PAGE - CHECK STRUCTURE

      #drop down in top right corner
      menu = session.find(:xpath, "//div[@id='header_global_container']//li[@id='userGroups']/a[@id='userGroups_List_open']")
      expect(menu).to_not be_nil
      #discussion link
      discussions_link = session.first(:xpath, "//a[@href='/group/forum?reset']")
      expect(discussions_link).to_not be_nil

      # NAVIGATE TO POSTS PAGE

      browser.a(:text => 'Discussions').click
      browser.input(name: 'forum_filter_basic[q]').wait_until_present
      expect(browser.title).to eq('bigtent/forum')

      session.find_link('Discussions').click

      # POSTS PAGE - CHECK STRUCTURE







      # NAVIGATE TO POSTS PAGE


      # session.driver.quit

      # fill_in 'index_login_user_name', :with => 'fam@2d12.net'
      # fill_in 'index_login_password', :with => 'bigtent567'
      # click_button 'submit_button'
      # session.visit('http://www.bigtent.com/group')

      #type in 'pets' as sample string in search box
      # browser.a(href: '/group/forum?reset', text: 'Discussions').click
      # browser.text_field(name: 'forum_filter_basic[q]').set("preschool")
      # browser.button(class: 'search_icon').click
      #
      # verify the resulting list of posts are in expected format
      # browser.strong(text: 'preschool').wait_until_present

    end
  end
end