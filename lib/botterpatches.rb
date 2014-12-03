# This file contains some monkey patches.

# Ruby-IRC: lib/IRC.rb
class IRC
  # The user/channel to reply to.
  def to(event)
    if event.channel == APP_CONFIG["nickname"]
      event.from
    else
      event.channel
    end
  end
end


# Ruby-IRC: lib/IRCEvent.rb
class IRCEvent
  def process
    handled = nil
    if $modules[:callbacks][@event_type.to_sym]
      $modules[:callbacks][@event_type.to_sym].each do |mod|
        Thread.new { mod.call(IRCBot.bot, self) }
      end
      handled = 1
    elsif @@handlers[@event_type]
      @@handlers[@event_type].call(self)
      handled = 1
    elsif @@callbacks[@event_type]
      @@callbacks[@event_type].call(self)
      handled = 1
    end
    if !handled
    end
  end
end