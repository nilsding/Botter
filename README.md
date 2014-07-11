# Botter

Botter is a modular IRC bot made with Ruby.  It uses Ruby-IRC to interact with
IRC servers.

## Features

* Google search (e.g. `!g apples`)
* DuckDuckGo ZeroClickInfo
* Display YouTube video data when a link is posted to a channel
* Extensible

## Requirements

* Ruby 1.9
* Bundler

Any operating system should work, as long as all the dependencies can be built.

## How to install

Install all the dependencies:

    % bundle install

Afterwards, edit `config.yml` to your needs:

    % vi config.yml

And finally start Botter:

    % ./bot.rb

(If that didn't work, try `bundle exec ruby bot.rb`)
