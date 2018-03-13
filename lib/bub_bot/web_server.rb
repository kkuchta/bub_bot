require 'bub_bot/slack/command_parser'
require 'bub_bot/slack/response'
require 'faraday'

class BubError < StandardError
end

# An error that should should result in a user-facing response (and not a non-200
# http response code)
class RespondableError < StandardError
end

class BubBot::WebServer
  def call(env)
    puts ' --- Got request ---'

    # Ignore retries for now.
    if env['HTTP_X_SLACK_RETRY_NUM']
      puts "Ignoring retry: #{env['HTTP_X_SLACK_RETRY_NUM']}, because #{env['HTTP_X_SLACK_RETRY_REASON']}"
      return [200, {}, ['ok']]
    end

    request = Rack::Request.new(env)

    # For easily checking if the server's up
    if request.path == '/' && request.get?
      return [200, {}, ['ok']]

    # When slack sends us a challenge request
    elsif request.path == '/' && request.post?
      params = parse_params(request)
      return [200, {}, [params[:challenge]]] if params[:challenge]

      event = params[:event]

      # Skip messages from bots
      return [200, {}, []] if event[:subtype] == 'bot_message'

      # Make sure this is in the form of 'bub foo'
      unless event[:text].starts_with?(BubBot.configuration.bot_name + ' ')
        puts "skipping non-bub message"
        return [200, {}, []]
      end

      command = BubBot::Slack::CommandParser.get_command(event[:text])

      puts " --- Running command #{command}"

      # Slack will retry any message that takes longer than 3 seconds to complete,
      # so do all message processing in a thread.
      Thread.new do
        response =
          begin
            if command
              command.new(event).run
            else
              BubBot::Slack::Response.new("unknown command")
            end
          rescue RespondableError => e
            BubBot::Slack::Response.new(e.message)
          end

        response.deliver
      end

      return [200, {}, []]

    #elsif request.path == '/heroku_hook' && request.post?
      #HerokuInterface.new.handle_heroku_webhook(request.body.read)
      #return [200, {}, []]
    else
      raise BubError, "Failed request: #{request.request_method} #{request.path}"
      err 'invalid request'
    end
  rescue BubError => e
    puts "Err: #{e.message}"
    return [400, {}, [e.message]]
  end

  private

  def parse_params(request)
    JSON.parse(request.body.read)
      .with_indifferent_access
  end
end
