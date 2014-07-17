require "bottermodule"

class BotterModule::Correction < BotterModule
  
  CORRECTION_REGEX = /^s\/([^\/]+)\/([^\/]+)\/?$/
  
  def initialize
    @config = APP_CONFIG["modules"]["config"]["correction"]
    raise "Please load the `logger' module first!" if $log_db.nil?
  end
  
  def privmsg(bot, event)
    match_data = CORRECTION_REGEX.match event.message
    if match_data
      subst = match_data[1]
      with = match_data[2]
      
      $log_db.execute("SELECT message, id FROM privmsgs WHERE msg_to = ? AND message LIKE ? AND message NOT LIKE \"s/%\" ORDER BY timestamp DESC LIMIT 1", [bot.to(event), "%#{subst}%"]) do |row|
        bot.send_message bot.to(event), "#{@config["banner"]} <#{event.from}> #{row[0].gsub(subst, with)}"
      end
    end
  end
end

$modules << {
  name: "Correction",
  authors: ["nilsding"],
  instance: (BotterModule::Correction).new
}

# kate: indent-width 2