require 'rack'
require "bub_bot/version"
require "bub_bot/web_server"
require "bub_bot/configuration"
require "bub_bot/cli"
require "pry-byebug"

module BubBot
  class << self
    attr_accessor :configuration
    # From a config.ru file you can do `run BubBot`.
    def call(env)
      WebServer.new.call(env)
    end

    def start
      puts "Booting BubBot, slack_token = #{BubBot.configuration.slack_token}"
      Thread.new do
        loop do
          puts "Checking for servers to shutdown"
          # TODO: actually do that ^
          sleep 10# * 60
        end
      end

      Rack::Handler::Thin.run(BubBot, BubBot.configuration.rack_options_hash)
    end

    def configure
      self.configuration ||= Configuration.new
      yield configuration
    end
  end
end
