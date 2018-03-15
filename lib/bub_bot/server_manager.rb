require 'bub_bot/redis_connection'

class BubBot::ServerManager
  ROOT_KEY = 'bub_server_list'.freeze

  # Options:
  # - duration (1.hour)
  # - server_name (cannoli)
  # - user (kevin)
  #
  # All options required.  Do your own defaulting, you lazy bum!
  def take(options)
    puts 'takin'

    server_name, duration, user = options.values_at(:server_name, :duration, :user)
    expires_at = duration.from_now

    data = {
      'user' => user,
      'expires_at' => expires_at
    }
    redis.hset(ROOT_KEY, server_name, data.to_json)

    data.merge(server: server_name)
  end

  def release(server_name)
    redis.hdel(ROOT_KEY, server_name)
  end

  def names
    known_server_names
  end

  def list
    claims = redis.hgetall(ROOT_KEY).to_h

    known_server_names.each_with_object({}) do |server_name, claim_map|
      claim_map[server_name] =
        if claim = claims[server_name]
          claim_data = JSON.parse(claim)
          expires_at = DateTime.parse(claim_data['expires_at'])

          # Filter out expired claims
          if expires_at > Time.now
            claim_data['expires_at'] = expires_at
            claim_data
          else
            {}
          end
        else
          {}
        end
    end
  end

  def claimed_by(username)
    list
      .select { |server, claim_data| claim_data['user'] == username }
      .keys
  end

  def first_unclaimed
    list.key({})
  end

  private

  def known_server_names
    BubBot.configuration.servers
  end

  def redis
    BubBot::RedisConnection.instance
  end
end
