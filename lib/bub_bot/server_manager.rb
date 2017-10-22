require 'redis'
class BubBot::ServerManager
  ROOT_KEY = 'bub_server_list'.freeze

  # Options:
  # - duration (1.hour)
  # - server_name (cannoli)
  # - username (kevin)
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

    puts 'done takin'
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
          claim_data['expires_at'] = expires_at < Time.now ? nil : expires_at
          claim_data
        else
          {}
        end
    end
  end

  def first_unclaimed
    list.key(nil)
  end

  private

  def known_server_names
    BubBot.configuration.servers
  end

  def redis
    # TODO: pull from config
    @redis ||= Redis.new(url: 'redis://localhost:6379')
  end
end
