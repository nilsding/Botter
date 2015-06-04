require "nokogiri"
require "httparty"

BotterModule.new.create 'youtube' do

  display_name 'YouTube info'
  description 'Displays some information about YouTube videos'
  author 'nilsding'

  YOUTUBE_URL_REGEX = /(?:https?:\/\/)?(?:www.)?(?:youtu.be|youtube.com)\/(?:watch\?v=)?([A-Za-z0-9\-_]+)/

  on_privmsg do |bot, event|
    match_data = YOUTUBE_URL_REGEX.match event.message
    if match_data
      video_id = match_data[1]
      data = get_data video_id
      
      if data[:success]
        bot.send_message bot.to(event), "#{@config["banner"]} #{data[:title]}"
        bot.send_message bot.to(event), "Uploaded by \x02#{data[:uploader]}\x0f, \x02#{data[:views]}\x0f views,\x039 #{data[:rating][:likes]}\x0f likes,\x034 #{data[:rating][:dislikes]}\x0f dislikes"
      elsif @config["enable_not_found_message"]
        bot.send_message bot.to(event), "#{@config["banner"]} #{@config["not_found_str"]}"
      end
    end
  end

  # helper methods

  def get_data(video_id)
    retdict = {
      success: false,
      rating: {
        likes: -1,
        dislikes: -1,
      },
      views: -1,
      title: "",
      uploader: ""
    }

    # shoutout to google for ruining developers' lives
    begin
      document = Nokogiri::XML.parse(HTTParty.get("https://youtube.com/watch?v=#{video_id}").parsed_response)

      # get the rating
      retdict[:rating][:likes], retdict[:rating][:dislikes] = document.css('.like-button-renderer .yt-uix-clickcard button:not(.hid) span.yt-uix-button-content').map { |x| x.content.gsub(/[',. ]/, '').to_i }

      # get the views, the title and the uploader's user name
      retdict[:views] = document.css('div.watch-view-count').first.content.gsub(/[',. ]/, '').to_i
      retdict[:title] = document.css('h1.watch-title-container span.watch-title').first.content.strip
      retdict[:uploader] = document.css('div.yt-user-info a').first.content.strip

      retdict[:success] = true
    rescue
      # ignored
    end

    retdict
  end
end
