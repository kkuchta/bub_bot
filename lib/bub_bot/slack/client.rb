require 'singleton'

# Just a simple wrapper around a slack connection.  Call .instance on this, then
# call anything you'd normally call on a Slack Client on object on this instead.  Eg
# `Client.instance.chat_postMessage`.
class BubBot::Slack::Client
  include Singleton
  def method_missing(method, *args, &block)
    client.respond_to?(method) ? client.public_send(method, *args, &block) : super
  end

  def client
    @client ||= Slack::Web::Client.new(token: BubBot.configuration.bot_oauth_token)
  end
end
