require 'sqlite3'

BotterModule.new.create 'quotes' do

  display_name 'Quote database'
  description 'A simple quote database.'
  author 'nilsding'

  on_privmsg do |bot, event|
    case event.message.strip
    when /^#{@config['commands']['add']}\s+(.+)$/
      msg = $1.strip
      action = 0
      case msg
      when /[\[<](\S+)[>\]]\s+(.+)/
      when /\*+\s+(\S+)\s+(.+)/
        action = 1
      else
        bot.send_message bot.to(event), "Please enter a quote in the format \x02<username> text\x0f or \x02* username text\x0f."
        next
      end
      author = $1
      content = $2
      @db.execute "INSERT INTO quotes (timestamp, author, content, added_by, is_action, deleted, channel) VALUES (?, ?, ?, ?, ?, ?, ?);",
                  [Time.new.strftime("%s").to_i, author, content, event.from, action, 0, bot.to(event)]
      bot.send_message bot.to(event), "Added quote with id #{@db.last_insert_row_id}"
    when /^#{@config['commands']['delete']}\s+(\d+)$/
      id = $1
      is_admin = @config['admins'].include?(event.from) and @config['admins'][event.from] == event.hostmask.gsub(/\A.+@/, '')
      fetched = false
      @db.execute("SELECT id, added_by, deleted FROM quotes WHERE id = ?;", [id.to_i]) do |row|
        fetched = true
        if row[2] == 1  # deleted
          bot.send_message bot.to(event), "Quote ##{id} has already been deleted."
          next
        end
        if row[1] != event.from and !is_admin  # added_by
          bot.send_message bot.to(event), "Thou shalt not delete this quote!"
          next
        end
        @db.execute("UPDATE quotes SET deleted = ? WHERE id = ?;", [1, id.to_i])
        bot.send_message bot.to(event), "Quote ##{id} has been deleted."
      end
      bot.send_message bot.to(event), "Quote ##{id} does not exist." unless fetched
    when /^#{@config['commands']['fetch']}(?:\s+(\d+))?/
      id = $1
      random = false
      if id.nil?
        id = @db.execute("SELECT id FROM quotes WHERE deleted = ? AND channel = ?;", [0], bot.to(event)).flatten.sample
        random = true
      end
      fetched = false
      @db.execute("SELECT id, timestamp, is_action, author, content, added_by, deleted, channel FROM quotes WHERE id = ? LIMIT 1;", [id.to_i]) do |row|
        fetched = true
        if row[6] == 1  # deleted
          bot.send_message bot.to(event), "Quote ##{id} has been deleted :("
          next
        end
        post_quote(bot, event, id, row[2], row[3], row[4], row[5], row[1], row[7], random)  # is_action, author, content, added_by, timestamp, channel
      end
      bot.send_message bot.to(event), "Quote ##{id} does not exist." unless fetched
    end
  end

  def init_db
    dirname = File.expand_path(File.dirname(@config['database']))
    if File.exists?(dirname) and !File.directory?(dirname)
      raise "File exists and it's not a directory: " + dirname
    else
      Dir.mkdir dirname unless File.exists? dirname
    end
    
    @db = SQLite3::Database.new File.expand_path @config['database']
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS quotes (
        id INTEGER PRIMARY KEY,
        timestamp NUMERIC,
        author TEXT,
        content TEXT,
        added_by TEXT,
        channel TEXT,
        is_action NUMERIC,
        deleted NUMERIC
      );
    SQL
  end

  def post_quote(bot, event, id, is_action, author, content, added_by, timestamp, channel, random)
    msg = if is_action == 0
            "<#{author}> #{content}"
          else
            "* #{author} #{content}"
          end
    bot.send_message bot.to(event), "\x02#{random ? "Random q" : "Q"}uote ##{id}:\x0f #{msg}"
    bot.send_message bot.to(event), "Added by \x02#{added_by}\x0f at #{Time.at(timestamp)}#{" in channel #{channel}" unless bot.to(event) == channel}"
  end
=begin
  def web_server
    require 'sinatra'
    QuoteDB::Web.start
  end
=end
  init_db
=begin
  web_server if @config['webserver']
=end
end
=begin
module QuoteDB
  class Web < Sinatra::Base
    set :views 
    get '/' do

    end
  end
end
=end
