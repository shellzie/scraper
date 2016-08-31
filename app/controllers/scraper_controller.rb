# require 'open-uri'
# require 'mechanize'

class ScraperController < ApplicationController

  def scrape_bigtent
    # doc = Nokogiri::HTML(open("http://www.bigtent.com/"))
    # render text: doc

    agent = Mechanize.new
    page = agent.get('http://www.bigtent.com')

    #click log in link in upper right corner
    page = page.link_with(:text => 'Log in').click

    #fill out login credentials
    login_form = page.form('form_index_login')
    login_form['index_login[user_name]'] = 'fam@2d12.net'
    login_form['index_login[password]'] = 'bigtent567'
    page = agent.submit(login_form)

    #arrive at home page for Highlands Mommies

    #click Discussions link in left panel
    page = page.link_with(:href => "/group/forum?reset").click

    #arrive at discussion page

    #type 'pediatrician' in search box
    search_form = page.form('form_forum_filter')
    search_form['forum_filter[q]'] = 'pediatrician'
    page = agent.submit(search_form)

    #all posts on pediatrician topic
    # "//" some descendant (multi levels down) vs "/" direct child (1 level down)
    #doc = page.parser.xpath("//table[@class='forums_index']//tr[@class='forum_message']//a[starts-with(@href, '/group/forum/message/')]/@href").to_html
    all_links = page.parser.xpath("//table[@class='forums_index']//tr[@class='forum_message']//a[starts-with(@href, '/group/forum/message/')]/@href")
    all_links.each do |link|
      post_page = agent.get("http://www.bigtent.com" + link.value)
      comments = post_page.parser.xpath("//ul[@class='message_list']/li[@class='comments']/ul[@class='comments_list']/li")
      comments.each do |comment|

        username_href = comment.xpath("div[@class='message_id']/p[@class='username']/a/@href").first.value
        username_temp = username_href.chomp("?trackback")
        #userid
        userid = username_temp[9..username_temp.length]

        #date
        date = comment.xpath("div[@class='message_id']/p[@class='date']").text

        #message
        message = comment.xpath("div[@class='message']/p[2]").text
        pattern = /(Dr.|Dr|dr|dr.)[^children]\s*(\w+)(.|\s*)(\w*)/


        match_obj = pattern.match message  #<MatchData "Word">

        if (match_obj != nil)
          dr_name = match_obj[2] + " " + match_obj[3] + " " + match_obj[4]
          debugger
          reco = Recommendation.create(userid: userid, post_date: date, doctor_name: dr_name)
        end
      end
    end

    render text: page
  end
end
