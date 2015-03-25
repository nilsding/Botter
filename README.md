# Botter

Botter is a modular IRC bot made with Ruby.  It uses Ruby-IRC to interact with
IRC servers.

## Features

* Google search (e.g. `!g apples`)
* DuckDuckGo ZeroClickInfo (e.g. `!d cats`)
* Resend a manually corrected message
* Display YouTube video data when a link is posted to a channel
* Display the contents of a tweet when a link is posted to a channel
* Post a new tweet to Twitter
* Extensible

## Requirements

* Ruby 2.0
* Bundler

Any operating system should work, as long as all the dependencies can be built.

## How to install

Install all the dependencies:

    % bundle install

Afterwards, copy the example configuration to `config.yml` and edit it to fit
your needs:

    % cp config.yml.example config.yml
    % vi config.yml

And finally start Botter:

    % ./bot.rb

(If that didn't work, try `bundle exec ruby bot.rb`)
