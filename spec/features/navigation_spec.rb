require 'spec_helper'
require 'byebug'
require 'mechanize'
require 'vcr'

describe 'User logs in' do
  it 'with valid email and password' do

    VCR.use_cassette('BigTentScraper', :record => :once) do
       response = Net::HTTP.get_response('www.bigtent.com', '/')
        puts "Response: #{response.body}"
    end
  end


    # byebug


    # agent = Mechanize.new
    # page = agent.get('http://www.bigtent.com')



    #
    # page = page.link_with(:text => 'Log in').click
    #
    #
    # login_form = page.form('form_index_login')
    # login_form['index_login[user_name]'] = 'fam@2d12.net'
    # login_form['index_login[password]'] = 'bigtent567'
    # page = agent.submit(login_form)
    # page_text = Nokogiri::HTML page
    # expect(page_text).to have_content('Log Out')


    # login_with 'fam@2d12.net', 'bigtent567'

    # visit 'http://www.bigtent.com/'
    # click_link 'Log in'
    # fill_in('index_login[user_name]', :with => email)
    # fill_in('index_login[password]', :with => password)
    # click_link 'Log in'
    #
    # expect(page).to have_content('Log Out')
    # expect(page).to have_content('Home')
    # expect(page).to have_content('Discussions')
    # expect(page).to have_content('Events')
    # expect(page).to have_content('Classifieds')
end