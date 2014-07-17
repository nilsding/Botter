require "bottermodule"

require "sqlite3"

class BotterModule::Logger < BotterModule
  
  def initialize
    @config = APP_CONFIG["modules"]["config"]["logger"]
    $log_db = SQLite3::Database.new ":memory:"
    $log_db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS privmsgs (
        id INTEGER PRIMARY KEY,
        timestamp NUMERIC,
        msg_from TEXT,
        msg_to TEXT,
        message TEXT
      );
    SQL
  end
  
  ##
  # log PRIVMSGs
  def privmsg(bot, event)
    $log_db.execute "INSERT INTO privmsgs (timestamp, msg_from, msg_to, message) VALUES (?, ?, ?, ?);",
                    [Time.new.strftime("%s").to_i, event.from, bot.to(event), event.message]
  end
end

$modules << {
  name: "Logger",
  authors: ["nilsding"],
  instance: (BotterModule::Logger).new
}

# kate: indent-width 2