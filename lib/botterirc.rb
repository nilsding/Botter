# Singleton?  Singleton.
class IRCBot
  class << self
    attr_reader :bot
  end

  private

  @bot = IRC.new(APP_CONFIG["nickname"], APP_CONFIG["server"], APP_CONFIG["port"], APP_CONFIG["realname"])
end