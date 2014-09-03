require "bottermodule"

class BotterModule::Correction < BotterModule
  
  CORRECTION_REGEX = /^s\/(.*?)\/([^\/]*)\/?$/
  
  def initialize
    @config = APP_CONFIG["modules"]["config"]["correction"]
    raise "Please load the `logger' module first!" if $log_db.nil?
  end
  
  def privmsg(bot, event)
    match_data = CORRECTION_REGEX.match event.message
    if match_data
      subst = match_data[1]
      with = match_data[2]
      
      $log_db.execute("SELECT message, msg_from, is_action, id FROM privmsgs WHERE msg_to = ? AND message LIKE ? AND message NOT LIKE \"s/%\" ORDER BY timestamp DESC LIMIT 1", [bot.to(event), "%#{subst}%"]) do |row|
        modified = row[0].gsub(subst, with)
        id = row[3]
        if row[2] == 0
          msg = "<#{row[1]}> #{modified}"
        else
          msg = "* #{row[1]} #{modified}"
        end
        if @config["save_correction"]
          puts "updating privmsg id #{id}" if APP_CONFIG["verbose"]
          $log_db.execute "UPDATE privmsgs SET message = ? WHERE id = ?", [modified, id]
        end
        bot.send_message bot.to(event), "#{@config["banner"]} #{msg}"
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