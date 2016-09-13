require 'spec_helper'
require 'byebug'
# require 'mechanize'
# require 'rspec'
# require 'vcr'
require 'watir-webdriver'


describe 'User logs in' do

  let(:browser) { @browser ||= Watir::Browser.new :firefox }
  before { browser.goto "http://www.bigtent.com/log_in" }
  after { browser.close }

  it "should land on login page" do
    browser.text_field(name: 'index_login[user_name]').set("fam@2d12.net")
    browser.text_field(name: 'index_login[password]').set("bigtent567")
    browser.a(id: 'submit_button').click
    browser.div(id: 'recent_forum_topics').wait_until_present
    expect(browser.title).to eq("bigtent/group")
  end

  # it 'logs user in with valid email and password'   #, :js => true do
  #   browser = Watir::Browser.new
  #   browser.goto 'http://www.bigtent.com'


    #
    # VCR.use_cassette('BigTentScraper', :record => :once) do
    #   response = Net::HTTP.get_response('www.bigtent.com', '/')
    #   static_html = response.body
    #   # byebug
    #   expect(static_html).to include('<label for="index_login_user_name"><span>Your Email</span></label>')
    #
    #   # page = Nokogiri::HTML static_html
    #   # page = page.link_with(:text => 'Log in').click
    #
    # end
end
