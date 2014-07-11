require "bottermodule"

require "google-search"

class BotterModule::GoogleSearch < BotterModule
  
  def initialize
    @config = APP_CONFIG["modules"]["config"]["google"]
  end
  
  ##
  # PRIVMSG event for Google Search
  def privmsg(bot, event)
    if /^#{@config["command"]} /.match event.message
      search_args = event.message.gsub "#{@config["command"]} ", ""
      bot.send_message bot.to(event), @config["searching_for_str"].gsub(/%arg/i, search_args)
      Google::Search::Web.new(query: search_args).each do |result|
        break if result.index > 2
        bot.send_message bot.to(event), "\x02#{result.index + 1}. #{result.title}"
        bot.send_message bot.to(event), "   #{result.content.gsub(/<\/?b>/, "\x02").gsub("\n", "")}"
        bot.send_message bot.to(event), "   \x039#{result.uri}"
      end
    end
  end
end

$modules << {
  name: "Google Search",
  authors: ["seatsea", "nilsding"],
  instance: (BotterModule::GoogleSearch).new
}

# kate: indent-width 2