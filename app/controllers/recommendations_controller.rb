require 'date'
class RecommendationsController < ApplicationController

  @@extra_words = ['at', 'is', 'there', 'in', 'for', 'actually', 'as', 'by', 'any', 'affectionately', 'gives', 'until',
    'more', 'or', 'and', 'www', 'F4', 'a', 'the', 'are', 'never', 'with', 'it', 'came', 'but', 'really', 'too', 'was',
    'does', 'that', 'of', 'over', 'saw', 'either', 'before', 'has', 'since', 'reminded', 'will', 'said', 'ok', 'we',
    'diagnosed', 'would', 'than', 'rec', 'also', 'based', 'called', 'during', 'head', 'once', 'really', 'simply', 'so',
    'took', 'vs', 'when', 'with', 'who', 'to', 'etc', 'told', 'today', 'Seems', 'because', 'walks', 'returned', 'will',
    'spends', 'out', 'site', 'Sears\' book', 'Sears\' The', 'doesn', 'off', 'speak', 'we', 'from']

  @@dr_prefixes = ['Dr.', 'Dr', 'dr.', 'dr']

  def new
    @recommendation = Recommendation.new
  end

  def create
    @existing_rec = Recommendation.find_by(params[:recommendation])
    if (@existing_rec.nil? || @existing_rec == "")
      @recommendation = Recommendation.new(recommendation_params)
      @recommendation.save
    else
      Rails.logger.info(@recommendation.errors.inspect)
    end
  end

  def show
    scrape_bigtent
    render text: "OK"
  end

  private

    def scrape_bigtent
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
      search_form = page.form('form_forum_filter_basic')
      search_form['forum_filter_basic[q]'] = 'pediatrician'
      page = agent.submit(search_form)

      #region
      region_text = page.parser.xpath("//div[@id='header_global_container']//li[@id='userGroups']/a[@id='userGroups_List_open']").text
      region_string = region_text.split(" ").join(" ")
      result = Region.find_by name: region_string
      if (!result.nil?)
        regionid = result.id
      end

      while (page.parser.xpath("//div[@class='forum_footer']/ul[@class='pagination']/li/a[@class='next']").text == 'Next') do #while there is a 'next' link at bottom of page
        scrape_page(page, agent, regionid)
        page = page.link_with(:text => 'Next').click
      end

      scrape_page(page, agent, regionid) #scrape the last page
      agent.shutdown #avoids the "too many connection reset" error
    end

    def scrape_page(page, agent, regionid)
      all_links = page.parser.xpath("//table[@class='forums_index']//tr[@class='forum_message']//a[starts-with(@href, '/group/forum/message/')]/@href")
      all_links.each do |link|
        post_page = agent.get("http://www.bigtent.com" + link.value)

        #topicid
        topic_info = post_page.parser.xpath("//div[@class='flag_container']/@id").first.value
        # topic_info = post_page.parser.xpath("//ul[@class='message_list']/li[@class='comments']/div[@class='flag_container']/@id").first.value
        topicid = topic_info[15..topic_info.length]

        comments = post_page.parser.xpath("//ul[@class='message_list']/li[@class='comments']/ul[@class='comments_list']/li")
        comments.each do |comment|
          #userid
          userid = nil
          if (comment.xpath("div[@class='message_id']/p[@class='username']/a/@href").present?) #user still has active account
            username_href = comment.xpath("div[@class='message_id']/p[@class='username']/a/@href").first.value
            username_temp = username_href.chomp("?trackback")
            userid = username_temp[9..username_temp.length]
          end

          #date
          date_str = comment.xpath("div[@class='message_id']/p[@class='date']").text
          dt = format_date(date_str)

          #didn't find a way to traverse cleanly because no root node is available. have to iterate over until node is nil
          #skip over first <p> because it's always empty
          message_node = comment.xpath("div[@class='message']/p").first.next
          combined_msg = ""

          while (message_node != nil)
            combined_msg += message_node.text + " "
            message_node = message_node.next
          end
          matches = find_dr_name_matches(combined_msg)

          #dr name
          matches.each do |match|
            if (match != nil && match[0] != "dren's") # throw out "children's" string
              if match[1].in?(@@extra_words) && match[2].in?(@@extra_words)
                #do nothing. don't insert random preposition words into DB
              elsif match[2].in?(@@extra_words) # includes a "throw away" word (first AND last name)
                dr_name = match[1]
                do_insert(userid, dt, dr_name, topicid, regionid)
              else
                dr_name = match[1] + " " + match[2]
                do_insert(userid, dt, dr_name, topicid, regionid)
              end
            end
          end
        end
      end
    end

    def format_date(raw_date)
      date_elts = raw_date.split("/")
      year = date_elts[2].to_i
      month = date_elts[0].to_i
      day = date_elts[1].to_i
      dateObj = Date.new(year, month, day)
      dt = dateObj.strftime('%Y-%m-%d')
      return dt
    end

    def find_dr_name_matches(message)
      #                0               1       2
      pattern = /(Dr|Dr.|dr|dr.)\s+(\w*'*)\s*(\w*'*)/
      removeInvalid = message.scrub()
      matches = removeInvalid.scan(pattern)
      return matches
    end

    def do_insert(userid, dt, dr_name, topicid, regionid)
      query_result = Recommendation.find_by user_id: userid, post_date: dt, doctor_name: dr_name, topic_id: topicid, region_id: regionid
      if query_result.nil?
        Recommendation.create(user_id: userid, post_date: dt, doctor_name: dr_name, topic_id: topicid, region_id: regionid)
      else
        # Rails.logger.debug "+++++++++++++++ record found. SKIPPING insert++++++++++++"
      end
    end

    def recommendation_params
      params.require(:recommendation).permit(:user_id, :post_date, :doctor_name, :topic_id)
    end
end
