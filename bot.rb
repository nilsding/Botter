#!/usr/bin/env ruby
require "rubygems"
require "IRC"
require "httparty"

begin
  resp = HTTParty.get('https://api.github.com/repos/Leafcat/Botter/commits', headers: {'User-Agent' => 'Mozilla/5.0'}).parsed_response
  if `git rev-parse HEAD`.chomp == resp[0]["sha"]
    puts "-- Up to date"
  else
    puts "-- An update is available, please run 'git pull' "
  end
rescue => e
  puts "Could not check for update #{e}"
end
	
APP_CONFIG = YAML.load_file(File.expand_path("config.yml", File.dirname(__FILE__)))["bot"]

$LOAD_PATH.unshift File.expand_path './lib', File.dirname(__FILE__)
require "bottermodule"

bot = IRC.new(APP_CONFIG["nickname"], APP_CONFIG["server"], APP_CONFIG["port"], APP_CONFIG["realname"])

APP_CONFIG["modules"]["enabled"].each do |mod|
  require "modules/#{mod}"
end

##
# The user/channel to reply to.
def bot.to(event)
  if event.channel == APP_CONFIG["nickname"]
    event.from
  else
    event.channel
  end
end

IRCEvent.add_callback('endofmotd') do |event|
  APP_CONFIG["channels"].each do |chan|
    # join all the channels
    bot.add_channel(chan)
  end
end

IRCEvent.add_callback('privmsg') do |event|
  $modules[:callbacks][:privmsg].each do |mod|
    Thread.new { mod.call(bot, event) }
  end
end

puts "connecting to #{bot.server}/#{bot.port}..." if APP_CONFIG["verbose"]
bot.connect

# kate: indent-width 2
