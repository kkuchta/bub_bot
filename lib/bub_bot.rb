require "bub_bot/version"
require "bub_bot/rack_handler"

module BubBot
  # From a config.ru file you can do `run BubBot`.
  def self.call(env)
    RackHandler.new.call(env)
  end
end
