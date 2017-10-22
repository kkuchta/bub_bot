class BubBot::Slack::Command::Claim < BubBot::Slack::Command

  # bub take cannoli for 20 minutes deploy master
  def self.aliases
    %w(claim take gimmee canhaz)
  end

  def run

    server = duration = deploy = nil

    # Just for testing
    servers.take( server_name: 'cannoli', duration: 1.hour, user: 'kevin')
    return respond('done')

    # This pattern is the new hotness.  Stuff below is wrong.  Haven't tested
    # in a while so create_token_iterator probably has a bug or two.
    iterator = create_token_iterator
    while token = iterator.peek

      if token == 'for'
        iterator.next
        duration = parse_duration(iterator)
      elsif token.to_i > 0
        duration = parse_duration(iterator)
      elsif server.names.include?(token)
        server = iterator.next
      elsif token == 'deploy'
        return respond('deploy not yet supported')
      end

    end

    take_options = {
      server_name: server,
      duration: duration,
      user: source_user_name
    }.compact
    # Defaulting should happen here

    result = servers.take(take_options)

    respond('Tookin!')
  end

  private

  def parse_duration(iterator)
    value = iterator.next.to_i
    # TODO: user-facing errors
    raise 'missing increment' unless increment = iterator.next
    raise 'bad increment' unless valid_increments.include?(increment)

    # 5.minutes
    value.public_send(increment)
  end

  def should_deploy?
    false # todo: parse from command, also support buttons
  end

  def valid_increments
    @@valid_increments ||= %w(minute hour day week month).reduce([]) do |valid, increment|
      valid << increment + 's'
      valid << increment
      valid
    end
  end
end
