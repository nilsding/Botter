require "nokogiri"
require "httparty"

BotterModule.new.create 'youtube' do

  display_name 'YouTube info'
  description 'Displays some information about YouTube videos'
  author 'nilsding'

  YOUTUBE_URL_REGEX = /(https?:\/\/)?(www.)?(youtu.be|youtube.com)\/(watch\?v=)?([A-Za-z0-9\-_]+)/

  on_privmsg do |bot, event|
    match_data = YOUTUBE_URL_REGEX.match event.message
    if match_data
      video_id = match_data[5]
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

    begin
      document = Nokogiri::XML.parse(HTTParty.get("https://gdata.youtube.com/feeds/api/videos/#{video_id}").parsed_response)

      # get the rating
      rating = document.xpath "//gd:rating"
      average = rating.attr("average").value.to_f
      total = rating.attr("numRaters").value.to_i
      retdict[:rating][:likes] = (total * (average - 1) / 4).round
      retdict[:rating][:dislikes] = total - retdict[:rating][:likes]

      # get the views, the title and the uploader's user name
      retdict[:views] = document.xpath("//yt:statistics").attr("viewCount").value.to_i
      retdict[:title] = document.xpath("//media:title").children.text
      retdict[:uploader] = document.xpath("//xmlns:author/xmlns:name").children.text

      retdict[:success] = true
    rescue
      # ignored
    end

    retdict
  end
end
