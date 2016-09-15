require 'spec_helper'
# require 'byebug'
# require 'watir-webdriver'
# require 'capybara'


describe "Create place scenario" do
  context "Go to home page" do

    #Node: need both capybara AND Watir or session AND browser throughout the tests. 1 for DOM tranversal, the other for
    #checking HTML structure.
    let(:browser) { @browser ||= Watir::Browser.new :firefox }   #for user interaction like clicking around and doing page navigation
    let(:session) { @session = Capybara::Session.new :selenium }
    after { browser.close }

    it "opens homepage" do

      #LOGIN PAGE - CHECK STRUCTURE

      # session = Capybara::Session.new :selenium # instantiate new session object (for inspecting it's layout)
      session.visit('http://www.bigtent.com/log_in')
      username = session.find(:xpath, "//form[@name='form_index_login']//li[@class='group']//input[@name='index_login[user_name]']")
      expect(username).to_not be_nil
      password = session.find(:xpath, "//form[@name='form_index_login']//li[@class='group']//input[@name='index_login[password]']")
      expect(password).to_not be_nil
      submit_btn = browser.a(:text => "Log in")
      expect(submit_btn).to_not be_nil

      #NAVIGATE TO LANDING PAGE

      browser.goto "http://www.bigtent.com/log_in"
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
      search_box = session.find(:xpath, "//form[@name='form_forum_filter_basic']//input[@name='forum_filter_basic[q]']")
      expect(search_box).to_not be_nil

      # NAVIGATE TO PRESCHOOL POSTS PAGE

      browser.text_field(name: 'forum_filter_basic[q]').set('preschool')
      browser.button(class: 'search_icon').click
      browser.strong(text: 'preschool').wait_until_present

      session.fill_in('forum_filter_basic[q]', :with => 'preschool')
      session.find_button('forum_filter_basic_submit_button_0').click

      # PRESCHOOL POSTS PAGE - CHECK STRUCTURE
      # next link
      next_link = session.find(:xpath, "//div[@class='forum_footer']/ul[@class='pagination']/li/a[@class='next']")
      check_presence(next_link)

      #find first post url that has at least 1 comment
      index = 0

      all_comment_counts = browser.tds(:class, 'forum_comments').to_a
      comment_details = all_comment_counts.slice(4, all_comment_counts.length)


      comment_details.each do |comment_count| #starts at 4th row and skips yellow rows
        if (comment_count.text.to_i > 0)
          @topic_url = browser.as(:css, '.forum_message .forum_topic p a')[4 + index].href
          @topic_title = browser.as(:css, '.forum_message .forum_topic p a')[4 + index].text
          break
        else
          index += 1
        end
      end
      check_presence(@topic_url)

      # NAVIGATE TO INDIVIDUAL TOPIC PAGE
      session.visit(@topic_url)
      browser.a(:text => @topic_title).click
      expect(browser.title).to eq('bigtent/forum/message')

      # INDIVIDUAL TOPIC PAGE - CHECK STRUCTURE
      userid = session.first(:xpath, "//div[@class='message_id']/p[@class='username']/a")[:href]
      check_presence(userid)

      topic = session.first(:xpath, "//ul[@class='message_list']/li[@class='comments']/ul[@class='comments_list']/li/div[@class='flag_container']",
                    visible: false)[:id]
      check_presence(topic)

      date = session.first(:xpath, "//div[@class='message_id']/p[@class='date']").text
      check_presence(date)

      message = session.first(:xpath, "//div[@class='message']/p")
      check_presence(message)

    end

    def check_presence(elt)
      expect(elt).to_not be_nil

    end
  end
end