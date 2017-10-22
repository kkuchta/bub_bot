require 'bub_bot/server_manager.rb'
require 'slack-ruby-client'

class BubBot::Slack::Command
  def self.can_handle?(command)
    aliases.include?(command)
  end

  def self.aliases
    # Guess the command name from the class name
    [self.name.demodulize.downcase]
  end

  def initialize(options)
    @options = options
    puts "initialized a command"
  end

  def run
    name = self.class.name
    raise "Your command #{name} needs to implement 'run'"
  end

  private

  def servers
    @@servers ||= BubBot::ServerManager.new
  end

  def client
    @@client ||= Slack::Web::Client.new(token: BubBot.configuration.bot_oauth_token)
  end

  def source_user_id
    @options['user']
  end

  def source_user_name
    # TODO: cache these, since it's probably the same few people most of the time.
    client.users_info(user: source_user_id)&.dig('user', 'name')
  end

  def tokens
    @tokens ||= @options['text'].split(' ')
  end

  # Takes either a string or some options
  def respond(options)
    BubBot::Slack::Response.new(options)
  end

  # Returns an iterator over the token list that returns nil when out of tokens.
  #
  # Eg if the tokens are `aaa bbb ccc`:
  #
  # iterator = create_token_iterator
  # iterator.next # aaa
  # iterator.next # bbb
  # iterator.next # ccc
  # iterator.next # nil
  #
  # A good way to use this is for parsing order-agnostic commands:
  #
  # iterator = create_token_iterator
  # while token = iterator.next
  #   if token == 'bake'
  #     recipe = iterator.next
  #     raise "bad recipe" unless %w(bread cookies).include?(recipe)
  #     bake(iterator.next)
  #   elsif token == 'order'
  #     raise 'missing type' unless food_type = iterator.next
  #     raise 'missing when' unless when = iterator.next
  #     order(food_type, when)
  #   end
  # end
  def create_token_iterator
    unsafe_iterator = tokens.each

    return Enumerator.new do |yielder|
      loop do
        yielder.yield unsafe_iterator.next
      end
      loop do
        yielder.yield nil
      end
    end
  end
end
