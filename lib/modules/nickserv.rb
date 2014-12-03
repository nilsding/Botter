BotterModule.new.create 'nickserv' do

  display_name 'NickServ'
  description 'Identifies with NickServ'
  author 'MeikoDis'

  on_privmsg do |bot, event|
    if /^#{@config["command"]}/.match event.message
      bot.send_message("nickserv", "identify #{@config["password"]}")
      puts "nickserv identify sent."
    end
  end
end
