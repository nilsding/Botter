require "google-search"

BotterModule.new.create 'google' do

  display_name 'Google Search'
  description "For when you don't want to open a web browser..."
  authors 'seatsea', 'nilsding'
  
  on_privmsg do |bot, event|
    if /^#{@config["command"]} /.match event.message
      search_args = event.message.sub /^#{@config["command"]} /, ""
      bot.send_message bot.to(event), @config["searching_for_str"].gsub(/%arg/i, search_args)
      Google::Search::Web.new(query: search_args).each_with_index do |result, index|
        break if index > 2
        bot.send_message bot.to(event), "\x02#{result.index + 1}. #{result.title}"
        bot.send_message bot.to(event), "   #{result.content.gsub(/<\/?b>/, "\x02").gsub("\n", "")}"
        bot.send_message bot.to(event), "   \x039#{result.uri}"
      end
    end
  end
end
