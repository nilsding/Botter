require 'twitter'

BotterModule.new.create 'twitter' do

  display_name 'Twitter'
  description 'Automatically expands tweets.'
  author 'nilsding'

  TWITTER_URL_REGEX = /(?:https?:\/\/)?(?:www.)?twitter\.com\/(?:[A-Za-z0-9_]+\/)?status(?:es)?\/(\d+)/

  @client = Twitter::REST::Client.new do |cfg|
    cfg.consumer_key        = @config['consumer_key']
    cfg.consumer_secret     = @config['consumer_secret']
    cfg.access_token        = @config['access_token']
    cfg.access_token_secret = @config['access_token_secret']
  end

  on_privmsg do |bot, event|
    match_data = TWITTER_URL_REGEX.match event.message
    if @config['tweet_enabled'] and /^#{@config["tweet_command"]} /.match event.message
      begin
        tweet = @client.update event.message.sub /^#{@config["tweet_command"]} /, ""

        bot.send_message bot.to(event), "#{@config["banner"]} ==> #{tweet.url}"
      rescue => e
        bot.send_message bot.to(event), "#{@config["banner"]} \x024Error:\x0f #{e.message}"
      end
    elsif match_data
      begin
        tweet = @client.status match_data[1].to_i

        bot.send_message bot.to(event), "#{@config["banner"]} \x02@#{tweet.user.screen_name}:\x0f #{tweet.text}"
        bot.send_message bot.to(event), "\x039 #{tweet.retweet_count}\x0f retweets,\x037 #{tweet.favorite_count}\x0f favorites"
      rescue => _e
      end
    end
  end
end
