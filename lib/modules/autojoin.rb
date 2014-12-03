BotterModule.new.create 'autojoin' do

  display_name 'AutoJoin'
  description 'Automatically joins channels upon connecting.'
  author 'nilsding'

  on_endofmotd do |bot, event|
    @config['channels'].each do |chan|
      bot.add_channel chan
    end
  end

  on_kick do |bot, event|
    return unless @config['rejoin_on_kick']
    if event.mode == bot.nick and @config['channels'].include? event.channel
      Thread.new do
        sleep @config['rejoin_wait']
        bot.add_channel event.channel
      end
    end
  end
end