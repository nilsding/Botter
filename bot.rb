#!/usr/bin/env ruby

require "rubygems"
require "IRC"
require "httparty"

$LOAD_PATH.unshift File.expand_path './lib', File.dirname(__FILE__)
APP_CONFIG = YAML.load_file(File.expand_path("config.yml", File.dirname(__FILE__)))["bot"]

begin
  resp = HTTParty.get('https://api.github.com/repos/Leafcat/Botter/commits', headers: {'User-Agent' => 'Mozilla/5.0'}).parsed_response
  unless `git rev-parse HEAD`.chomp == resp[0]["sha"]
    puts "-- An update is available, please run 'git pull'."
  end
rescue => e
  puts "Could not check for update: #{e}"
end

require "bottermodule"
require "botterpatches"
require "botterirc"

# Load ALL the modules!
APP_CONFIG["modules"]["enabled"].each do |mod|
  require "modules/#{mod}"
end

puts "-- connecting to #{IRCBot.bot.server}/#{IRCBot.bot.port}..." if APP_CONFIG["verbose"]
IRCBot.bot.connect
