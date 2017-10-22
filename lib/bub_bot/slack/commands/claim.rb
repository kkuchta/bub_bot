class BubBot::Slack::Command::Claim < BubBot::Slack::Command

  DEFAULT_DURATION = 1.hour.freeze
  INCREMENTS = %w(minute hour day week month)

  # bub take cannoli for 20 minutes deploy master
  def self.aliases
    %w(claim take gimmee canhaz)
  end

  def run
    server = duration = deploy = nil

    # This pattern is the new hotness.  Stuff below is wrong.  Haven't tested
    # in a while so create_token_iterator probably has a bug or two.
    iterator = create_token_iterator

    # Skip the command name itself
    iterator.next

    while token = iterator.peek
      if token == 'for'
        puts 'got for'
        iterator.next
        duration = parse_duration(iterator)
      elsif token.to_i > 0
        puts 'got int'
        duration = parse_duration(iterator)
      elsif servers.names.include?(token)
        puts 'got server'
        server = iterator.next
      elsif token == 'deploy'
        puts 'got deploy'
        return respond('deploy not yet supported')
      else
        raise RespondableError.new("I'm not sure what '#{token}' means.")
      end
    end

    # Default to the first unclaimed server if no server was specified.  If there
    # are no unclaimed servers, error.
    unless server
      unless server = servers.first_unclaimed
        raise RespondableError.new("No available servers.")
      end
    end

    duration ||= DEFAULT_DURATION

    take_options = {
      server_name: server,
      duration: duration,
      user: source_user_name
    }.compact

    result = servers.take(take_options)

    respond('Tookin!')
  end

  private

  def parse_duration(iterator)
    value = iterator.next.to_i
    unless increment = iterator.next
      raise RespondableError.new("Missing increment.  Do you mean '#{value} hours'?")
    end
    unless valid_increments.include?(increment)
      raise RespondableError.new("I don't know the increment '#{increment}'.  Try one of these instead: #{INCREMENTS.join(', ')}")
    end

    # 5.minutes
    value.public_send(increment)
  end

  def should_deploy?
    false # todo: parse from command, also support buttons
  end

  def valid_increments
    @@valid_increments ||= INCREMENTS.reduce([]) do |valid, increment|
      valid << increment + 's'
      valid << increment
      valid
    end
  end
end
