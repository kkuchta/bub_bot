require 'faraday'

class BubBot::Slack::Response
  attr_accessor :text
  def initialize(options)
    @text = options.is_a?(String) ? options : options[:text]
  end

  def deliver
    body = {
      text: text,
      username: 'bub'
    }
    Faraday.post(BubBot.configuration.slack_url, body.to_json)
  end
end
