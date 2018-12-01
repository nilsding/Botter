BotterModule.new.create 'help' do

  display_name 'help'
  description "Posts a link to the rrerrNet IRC Wiki"
  author 'nilsding'
  
  on_privmsg do |bot, event|
    if @config["command"].strip == event.message.strip
      bot.send_message bot.to(event), "\x02#{@config['url']}"
    end
  end
end
