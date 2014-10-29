require "bottermodule"

class BotterModule::NickServ < BotterModule

  def initialize
    @config = APP_CONFIG["modules"]["config"]["nickserv"]
  end

  def privmsg(bot, event)
    if /^#{@config["command"]}/.match event.message
      bot.send_message("nickserv", "identify #{@config["password"]}")
      puts "nickserv identify sent."
    end
  end
end

$modules << {
  name: "NickServ",
  authors: ["MeikoDis"],
  instance: (BotterModule::NickServ).new
}    
