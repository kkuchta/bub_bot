class BubBot::Slack::Command::Release < BubBot::Slack::Command
  def run
    puts "Running release"
    servers_to_release = tokens.drop(1)
    puts "servers_to_release: #{servers_to_release}"

    my_servers = servers.claimed_by(source_user_name)
    servers_to_release = 
      if servers_to_release.empty?
        my_servers
      else
        servers_to_release & my_servers
      end

    if (unknown_servers = servers_to_release - servers.names).any?
      raise RespondableError.new("Unknown server(s): #{unknown_servers.join(', ')}.  Nothing released.")
    end

    servers_to_release.each do |server|
      servers.release(server)
    end

    released = servers_to_release.any? ? servers_to_release.join(', ') : 'nothing'
    respond("Released #{released}")
  end
end
