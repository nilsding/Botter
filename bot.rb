#!/usr/bin/env ruby19
require "rubygems"
require "IRC"
require "duck_duck_go"
require "google-search"

APP_CONFIG = YAML.load_file(File.expand_path("config.yml", File.dirname(__FILE__)))["bot"]

##
# The user/channel to reply to.
def to (event)
  if event.channel == APP_CONFIG["nickname"]
    event.from
  else
    event.channel
  end
end

bot = IRC.new(APP_CONFIG["nickname"], APP_CONFIG["server"], APP_CONFIG["port"], APP_CONFIG["realname"])
ddg = DuckDuckGo.new

IRCEvent.add_callback('endofmotd') do |event|
  APP_CONFIG["channels"].each do |chan|
    bot.add_channel(chan)
  end
end

IRCEvent.add_callback('privmsg') do |event|
  if /^!d/.match event.message # DuckDuckGo! ZeroClickInfo
    search_args = event.message.gsub "!d ", ""
    bot.send_message to(event), "Searching \x034DuckDuckGo\x0f for: #{search_args}"
  	zci = ddg.zeroclickinfo search_args

    case zci.type # see https://github.com/andrewrjones/ruby-duck-duck-go/blob/master/lib/duck_duck_go/zero_click_info.rb#L11-L15
    when 'A'
      bot.send_message to(event), zci.abstract_text
      bot.send_message to(event), "See #{zci.abstract_url.to_s}"
    when 'D'
      zci.related_topics['_'].each_with_index do |topic, i|
        bot.send_message to(event), "\x02#{i + 1}.\x02 #{topic.text}" # \x02 - bold text in IRC
      end
    when 'C'
    when 'N'
    when 'E'
      bot.send_message to(event), zci.answer
    else
      bot.send_message to(event), "Nothing was found :("
    end
  elsif /^!g /.match event.message # Google
    search_args = event.message.gsub "!g ", ""
    bot.send_message to(event), "Searching \x0312G\x034o\x038o\x0312g\x039l\x034e\x0f for: #{search_args}" # \x03 - colours in IRC ; \x0f - reset formatting
    Google::Search::Web.new(query: search_args).each do |result|
      break if result.index > 2
      bot.send_message to(event), "\x02#{result.index + 1}. #{result.title}"
      bot.send_message to(event), "   #{result.content.gsub(/<\/?b>/, "\x02").gsub("\n", "")}"
      bot.send_message to(event), "   \x039#{result.uri}"
    end
  elsif /^\x01/.match event.message # CTCP message
    message = event.message.gsub /^\x01|\x01$/, '' # strip \x01 from the beginning and the end of the message
    ctcp = message.match /^([A-Z])+(.*)?/
    ctcp_type = ctcp[0]
    ctcp_message = ctcp[2].gsub(/ ?:?/, '')
    case ctcp_type
    when 'VERSION'
      bot.send_ctcpreply(event.from, 'VERSION', "Botter:git-#{`git rev-parse --short HEAD`.chomp}:#{`uname -s`.chomp}@#{`uname -n`.chomp}")
    end
  end
end

bot.connect
