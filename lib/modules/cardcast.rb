require 'httparty'
require 'json'

BotterModule.new.create 'cardcast' do

  display_name 'Cardcast'
  description "Random card combination from a Cardcast deck"
  author 'nilsding'
  
  on_privmsg do |bot, event|
    if @config["commands"]["default"].strip == event.message.strip
      bot.send_message bot.to(event), get_new_card
    elsif @config["commands"]["force"].strip == event.message.strip
      bot.send_message bot.to(event), get_new_card(true)
    end
  end

  def get_deck(force = false)
    cardcast_cards_url = "https://api.cardcastgame.com/v1/decks/#{@config['deck']}/cards"
    if @deck.nil? or force
      @deck = JSON.parse HTTParty.get(cardcast_cards_url).body
    end
    @deck
  end

  def get_new_card(force = false)
    @combinations ||= []
    deck = get_deck(force)
    calls = make_calls deck
    responses = make_responses deck
    combination = ""
    until @combinations.include? combination do
      combination = calls.shuffle!.sample.gsub "\x00" do
        response = responses.shuffle!.sample
        responses.delete_at responses.index(response)
        "\x1F#{response}\x1F"
      end
      @combinations << combination
    end
    combination
  end

  def make_calls(deck)
    deck['calls'].map do |c|
      c['text'] * "\x00"  # ____ == \x00
    end.flatten
  end

  def make_responses(deck)
    deck['responses'].map do |r|
      r['text']
    end.flatten
  end

  # initial load of card deck
  get_deck true
end
