require 'faraday'
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
    raise "Not implemented"
  end

  def send_message(message)
    #BubBot.configuration.slack_url
    body = {
      text: message,
      username: 'bub'
    }
    Faraday.post(BubBot.configuration.slack_url, body.to_json)

    puts 'here'
  end
end
