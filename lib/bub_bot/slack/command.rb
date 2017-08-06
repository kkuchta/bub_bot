require 'bub_bot/server_manager.rb'

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

  def respond(options)
    BubBot::Slack::Response.new(options)
  end

  def servers
    @servers ||= BubBot::ServerManager.new
  end
end
