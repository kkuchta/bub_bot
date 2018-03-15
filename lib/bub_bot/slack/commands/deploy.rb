class BubBot::Slack::Command::Deploy < BubBot::Slack::Command
  def self.aliases
    %w(deploy ship push)
  end

  # bub deploy cannoli core kk_foo
  def run
    puts 'deploying'
    server = nil
    deploys = {}
    iterator = create_token_iterator

    # Skip the command name itself
    iterator.next

    while token = iterator.peek
      puts "token loop #{token}"
      if token == 'and'
        iterator.next
        next
      end

      # TODO: strip trailing commas (need to do this in the iterator)
      #token = token.sub!(/,$/, '')

      if servers.names.include?(token)
        puts 'servers.names'
        server = iterator.next

      # Handle 'kk_some_fix [to] core'
      elsif branches.include?(token)
        puts 'branches.include'
        
        branch = iterator.next
        target = iterator.next

        # Skip connector words
        target = iterator.next if %w(to on with).include?(target)

        deploys[target] = branch

      # Handle 'core kk_some_fix'
      elsif targets.include?(token)
        puts 'else targets.inclue'
        target = iterator.next
        branch = iterator.next
        deploys[target] = branch
      else
        raise RespondableError.new("I didn't recognize #{token}")
      end
    end

    # Validate all the potential deploys before we start
    deploys.each do |target, branch|
      puts 'deploys.each'
      # TODO: infer targets, etc
      unless targets.include?(target)
        raise RespondableError.new("Unknown deploy target #{token}. Try one of #{targets.join(', ')}")
      end
      unless branches(target).include?(branch)
        raise RespondableError.new("Deploy target #{target} doesn't have a branch named #{branch}.  Maybe you forgot to push that branch?")
      end
    end

    server = servers.first_unclaimed unless server

    unless server
      return respond('No servers available')
    end

    unless deploys.any?
      return respond("Please specify a target and a branch, eg `#{bot_name} deploy #{server} core kk_add_lasers`");
    end

    # TODO:
    # - default to deploying develop

    claim_data = servers.list[server]

    if claim_data['user'] && claim_data['user'] != source_user_name
      raise RespondableError.new("Server already claimed by #{claim_data['user']}.  Use the 'take' command first to override their claim.")
    elsif
      # Extend our current claim on this server to 1 hour from now unless we
      # already have it claimed for longer
      if !claim_data['expires_at'] || claim_data['expires_at'] < 1.hour.from_now
        servers.take(
          user: source_user_name,
          duration: 1.hour,
          server_name: server
        )
      end
    end

    message_segments = deploys.map do |target, branch|
      "branch '#{branch}' to target '#{target}'"
    end
    respond("Deploying on server #{server}: #{message_segments.join('; ')}").deliver

    deploys.each do |target, branch|
      deployer.deploy(server, target, branch)
    end

    respond("Finished deploying on server #{server}: #{message_segments.join('; ')}");
  end

  # All known branches for the given target.  Returns all branches for *all*
  # targets if target is nil.
  def branches(target = nil)
    puts 'deploy.branches'
    @_branch_cache ||= {}
    if target == nil
      targets.flat_map do |target|
        branches(target)
      end
    else
      @_branch_cache[target] ||= deployer.branches(target)
    end
  end

  def targets
    deployer.target_names
  end
end
