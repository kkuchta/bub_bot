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
    
  end

  def respond(options)
    BubBot::Slack::Response.new(options)
  end

end
