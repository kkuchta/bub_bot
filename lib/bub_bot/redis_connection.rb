require 'redis'
require 'singleton'

# Just a simple wrapper around a redis connection.  Call .instance on this, then
# call anything you'd normally call on a Redis on object on this instead.  Eg
# `RedisConnection.instance.hgetall(...)`.
class BubBot::RedisConnection
  include Singleton

  def method_missing(method, *args, &block)
    redis.respond_to?(method) ? redis.public_send(method, *args, &block) : super
  end
  def redis
    @redis ||= Redis.new(url: 'redis://' + BubBot.configuration.redis_host)
  end
end
