#!/usr/bin/env ruby19
require "rubygems"
require "IRC"
require "duck_duck_go"

ddg = DuckDuckGo.new

bot = IRC.new("botter", "irc.rrerr.net", "6667", "Botter IRC Bot")

IRCEvent.add_callback('endofmotd') do |event|
  bot.add_channel('#lobby')
end

IRCEvent.add_callback('privmsg') do |event|
  if /^!search /.match event.message
    search_args = event.message.gsub "!search ", ""
    bot.send_message '#lobby', "Searching for: #{search_args}"
  	zci = ddg.zeroclickinfo search_args
  	bot.send_message  '#lobby', zci.related_topics['_'][0].text
  end
 # bot.send_message '#lobby', event.message
end

bot.connect
