class Bot < ApplicationRecord
  CLIENT = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['consumer_key']
    config.consumer_secret = ENV['consumer_secret']
    config.access_token = ENV['access_token']
    config.access_token_secret = ENV['access_token_secret']
  end

  def self.search_words words
    CLIENT.search(words, lang: "en").first.text
  end

  def self.tweet words
    CLIENT.update(words)
  end

  def self.respond name
    "@" + name + " " + Reply.order_by_rand.first.tweet
  end

  def self.find_user number, words
    CLIENT.search(words, lang: "en").take(number).each { |t|
      user_name = t.user.screen_name
      unless User.exists?(name: user_name)
        User.create(name: t.user.screen_name, tweet_id: t.id.to_s)
        CLIENT.update(Bot.respond(t.user.screen_name), in_reply_to_status_id: t.id)
      else
        puts 'already tweeted to this user'
      end
    }
  end

  def self.test number, words
    number.times do |t|
      t = CLIENT.search(words, lang: "en").take(number).map.user.screen_name
      puts t

      # user_name = t.user.screen_name
      #
      # unless User.exists?(name: user_name)
      #   puts 'you can tweet to them'
      #   count += 1
      #   puts 'count is', count
      # else
      #   puts 'already tweeted to this user'
      #   puts 'count is', count
      #   number += 1
      #   puts 'number is', number
      # end
    end
  end

  def self.test2 number, words
    count = number
    while count > 0 do
      CLIENT.search(words, lang: "en").take(number).each { |t|
        user_name = t.user.screen_name
        unless User.exists?(name: user_name)
          puts 'you can tweet to them'

          puts count
        else
          puts 'already tweeted to this user'
          count += 1
        end
      }
      count = number - count
      puts count, number

    end
  end

end
