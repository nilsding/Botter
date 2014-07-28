#!/usr/bin/env ruby19
require "rubygems"
require "IRC"

version = HTTParty.get('https://api.github.com/repos/seatsea/Botter/commits')
body = JSON.parse(response.body)
version = body["sha"]
puts version

APP_CONFIG = YAML.load_file(File.expand_path("config.yml", File.dirname(__FILE__)))["bot"]
$:.unshift File.expand_path './lib', File.dirname(__FILE__)

bot = IRC.new(APP_CONFIG["nickname"], APP_CONFIG["server"], APP_CONFIG["port"], APP_CONFIG["realname"])

$modules = []

APP_CONFIG["modules"]["enabled"].each do |mod|
  require "modules/#{mod}"
  puts "--> #{$modules[-1][:name]} by #{$modules[-1][:authors].join ", "}" if APP_CONFIG["verbose"]
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
  $modules.each do |mod|
    mod[:instance].privmsg(bot, event)
  end
end

puts "connecting to #{bot.server}/#{bot.port}..." if APP_CONFIG["verbose"]
bot.connect

# kate: indent-width 2
