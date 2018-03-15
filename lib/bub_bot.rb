require 'rack'
require 'bub_bot/version'
require 'bub_bot/web_server'
require 'bub_bot/configuration'
require 'bub_bot/cli'
require 'pry-byebug'
require 'active_support'
require 'active_support/core_ext'

module BubBot
  class << self
    attr_accessor :configuration
    # From a config.ru file you can do `run BubBot`.  TODO: maybe not.  That would
    # skip the running background thread.
    #
    # Handle an individual web request.  You shouldn't call this method directly.
    # Instead, give BubBot to Rack and let it call this method.
    def call(env)
      (@web_server ||= WebServer.new).call(env)
    end

    # This method starts a listening web server.  Call from the cli or wherever
    # else you want to kick off a running BubBot process.
    def start
      puts 'Booting BubBot'
      Thread.new do
        loop do
          #puts "Checking for servers to shutdown"
          # TODO: actually do that ^
          sleep 10# * 60
        end
      end

      app = Rack::Builder.new do
        # if development (TODO)
          use Rack::Reloader
        # end
        run BubBot
      end.to_app

      Rack::Handler::Thin.run(app, BubBot.configuration.rack_options_hash)
    end

    # Used for setting config options:
    #   BubBot.configure do |config|
    #     config.bot_name 'lillian'
    #     config.redis_host 'localhost:6379'
    #   end
    def configure
      self.configuration ||= Configuration.new
      yield configuration
    end
  end
end
