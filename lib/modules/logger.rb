require "bottermodule"

class BotterModule::Logger < BotterModule
  
  def initialize
    @config = APP_CONFIG["modules"]["config"]["logger"]
    $logs = {}
  end
  
  ##
  # log PRIVMSGs
  def privmsg(bot, event)
    $logs[bot.to(event)] ||= {privmsgs: []}
    $logs[bot.to(event)][:privmsgs] << {
      timestamp: Time.now,
      from: event.from,
      message: event.message
    }
  end
end

$modules << {
  name: "Logger",
  authors: ["nilsding"],
  instance: (BotterModule::Logger).new
}