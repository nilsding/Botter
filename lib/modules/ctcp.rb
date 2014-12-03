BotterModule.new.create 'ctcp' do

  display_name 'CTCP'
  description 'Responds to CTCP events'
  author 'nilsding'

  # PRIVMSG event for CTCP
  # CTCP requests and replies are sent through PRIVMSGs, but they have
  # \x01 at the beginning and at the end of the message content.
  # See also: http://www.irchelp.org/irchelp/rfc/ctcpspec.html
  on_privmsg do |bot, event|
    if /^\x01/.match event.message
      message = event.message.gsub /^\x01|\x01$/, '' # strip \x01 from the beginning and the end of the message
      ctcp = message.match /^([A-Z])+(.*)?/
      ctcp_type = ctcp[0].upcase
      ctcp_message = ctcp[2].gsub(/ ?:?/, '')
      case ctcp_type
      when 'VERSION'
        if @config["version"]
          begin
            version = "#{`git rev-parse --short HEAD`.chomp} "
          rescue
            version = ""
          end
          bot.send_ctcpreply(event.from, 'VERSION', "Botter #{version}by Leafcat - https://github.com/Leafcat/Botter")
        end
      end
    end
  end
end
