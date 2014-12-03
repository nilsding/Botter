BotterModule.new.create 'correction' do

  display_name 'Correction'
  author 'nilsding'
  depends 'logger'

  CORRECTION_REGEX = /^s\/(.*?)\/([^\/]*)\/?$/

  on_privmsg do |bot, event|
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
