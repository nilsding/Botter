require "IRC"

class BotterModule
  
  def self.inherited(subclass)
    puts "loading #{subclass}" if APP_CONFIG["verbose"]
  end
  
  ##
  # callback for an PRIVMSG event
  def privmsg(bot, event)
    
  end
end

# kate: indent-width 2