class BubBot::Slack::Command::Echo < BubBot::Slack::Command
  def run
    respond(@options[:text])
  end
end
