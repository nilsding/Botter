require "duck_duck_go"

BotterModule.new.create 'ddg' do

  display_name 'DuckDuckGo ZeroClickInfo'
  authors 'seatsea', 'nilsding'

  ddg = DuckDuckGo.new

  on_privmsg do |bot, event|
    if /^#{@config["command"]} /.match event.message
      search_args = event.message.gsub /^#{@config["command"]} /, ""
      bot.send_message bot.to(event), @config["searching_for_str"].gsub(/%arg/i, search_args)
      zci = ddg.zeroclickinfo search_args

      case zci.type # see https://github.com/andrewrjones/ruby-duck-duck-go/blob/master/lib/duck_duck_go/zero_click_info.rb#L11-L15
      when 'A'
        bot.send_message bot.to(event), zci.abstract_text
        bot.send_message bot.to(event), "See #{zci.abstract_url.to_s}"
      when 'D'
        zci.related_topics['_'].each_with_index do |topic, i|
          break if i >= 10
          bot.send_message bot.to(event), "\x02#{i + 1}.\x02 #{topic.text}" # \x02 - bold text in IRC
        end
      when 'C'
      when 'N'
      when 'E'
        bot.send_message bot.to(event), zci.answer
      else
        bot.send_message bot.to(event), @config["no_results_str"]
      end
    end
  end
end
