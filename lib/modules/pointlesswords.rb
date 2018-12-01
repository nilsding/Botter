require 'httparty'
require 'htmlentities'

BotterModule.new.create 'pointlesswords' do

  display_name 'PointlessWords'
  description "German words that don't make sense."
  author 'nilsding'
  
  on_privmsg do |bot, event|
    if @config["command"].strip == event.message.strip
      begin
        word = HTMLEntities.new.decode HTTParty.get('http://dev.revengeday.de/pointlesswords/api/').force_encoding(Encoding::UTF_8)
        bot.send_message bot.to(event), word
      rescue => _
      end
    elsif "!wurst" == event.message.strip
      begin
        word = HTMLEntities.new.decode HTTParty.get('http://dev.revengeday.de/pointlesswords/api/').force_encoding(Encoding::UTF_8)
        bot.send_message bot.to(event), "#{word}wurst"
      rescue => _
      end
    end
  end
end
