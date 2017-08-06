require 'redis'
class BubBot::ServerManager
  ROOT_KEY = 'bub_server_list'

  # Options:
  # - duration (required)
  # - server_name (optional)
  def take(options)
    puts 'takin'

    server_name, duration, user = options.values_at(:server_name, :duration, :user)
    expires_at = duration.from_now

    data = {
      'user' => user,
      'expires_at' => expires_at
    }
    redis.hset(ROOT_KEY, server_name, data.to_json)

    puts 'done takin'
  end

  def list
    all_claims = redis.hgetall(ROOT_KEY)

    all_claims
      .slice(*known_server_names) # Remove old claims
      .each_with_object({}) do |(server, claim), claim_map|
        claim = JSON.parse(claim)
        expires_at = DateTime.parse(claim['expires_at'])
        claim['expires_at'] = expires_at < Time.now ? nil : expires_at
        claim_map[server] = claim
      end
  end

  private

  def known_server_names
    BubBot.configuration.servers
  end

  def redis
    # TODO pull from config
    @redis ||= Redis.new(url: 'redis://localhost:6379')
  end
end
