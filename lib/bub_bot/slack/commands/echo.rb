class BubBot::Slack::Command::Echo < BubBot::Slack::Command
  def run
    send_message(@options[:text])
  end
end
