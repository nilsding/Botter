#!/usr/bin/env ruby19
require "rubygems"
require "IRC"

bot = IRC.new("botter", "irc.rrerr.net", "6667", "Botter IRC Bot")
IRCEvent.add_callback('endofmotd') do |event|
  bot.add_channel('#lobby')
end
bot.connect
