#!/usr/bin/env ruby19
require "rubygems"
require "IRC"
require "duck_duck_go"

ddg = DuckDuckGo.new

bot = IRC.new("botter2", "irc.rrerr.net", "6667", "Botter IRC Bot")

IRCEvent.add_callback('endofmotd') do |event|
  bot.add_channel('#lobby')
end

IRCEvent.add_callback('privmsg') do |event|
  if /^!search /.match event.message
    search_args = event.message.gsub "!search ", ""
    bot.send_message '#lobby', "Searching for: #{search_args}"
  	zci = ddg.zeroclickinfo search_args

    case zci.type # see https://github.com/andrewrjones/ruby-duck-duck-go/blob/master/lib/duck_duck_go/zero_click_info.rb#L11-L15
    when 'A'
      bot.send_message '#lobby', zci.abstract_text
      bot.send_message '#lobby', "See #{zci.abstract_url.to_s}"
    when 'D'
      zci.related_topics['_'].each_with_index do |topic, i|
        bot.send_message '#lobby', "\x02#{i + 1}.\x02 #{topic.text}" # \x02 - bold text in IRC
      end
    when 'C'
    when 'N'
    when 'E'
      bot.send_message '#lobby', zci.answer
    else
      bot.send_message '#lobby', "Nothing was found :("
    end

  end
 # bot.send_message '#lobby', event.message
end

bot.connect
