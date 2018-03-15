class BubBot::Slack::Response
  attr_accessor :text

  def initialize(options, client)
    @text = options.is_a?(String) ? options : options[:text]
    @client = client
  end

  def deliver
    body = {
      text: text,
      username: BubBot.configuration.bot_name
    }
    # TODO: configure channel
    @client.chat_postMessage(channel: '#' + channel, text: text, as_user: true)
  end

  def channel
    BubBot.configuration.slack_channel
  end
end
