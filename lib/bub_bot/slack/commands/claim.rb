class BubBot::Slack::Command::Claim < BubBot::Slack::Command

  def self.aliases
    %w(claim take gimmee canhaz)
  end

  def run
    respond('takin')

    take_options = {
      server_name: server_name,
      duration: duration,
      user: user
    }.compact
    # Defaulting should happen here

    result = servers.take(take_options)

    respond('Tookin!')
  end

  private

  def server_name
    'cannoli' # todo: parse from command
  end

  def user
    'kevin' # todo: somehow
  end

  def duration
    1.hour # todo: parse from command
  end

  def should_deploy?
    false # todo: parse from command, also support buttons
  end
end
