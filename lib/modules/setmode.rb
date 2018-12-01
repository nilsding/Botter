BotterModule.new.create 'setmode' do

  display_name 'setmode'
  description 'Automatically sets user mode upon connecting.'
  author 'nilsding'

  on_endofmotd do |bot, event|
    IRCConnection.send_to_server("MODE #{APP_CONFIG["nickname"]} +B")
    IRCConnection.send_to_server("MODE #{APP_CONFIG["nickname"]} -x")
    #bot.mode bot.nick "+B", ''
    #bot.mode bot.nick "-x", ''
  end
end
