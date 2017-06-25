require 'bub_bot/slack/command_parser'

class BubError < StandardError
end

class BubBot::WebServer
  def call(env)
    puts 'got something'
    request = Rack::Request.new(env)

    # For easily checking if the server's up
    if request.path == '/' && request.get?
      return [200, {}, ['ok']]
    elsif request.path == '/' && request.post?
      params = parse_params(request)
      return [200, {}, [params[:challenge]]] if params[:challenge]

      # command = first_arg
      # klass = find_command_class(command)
      # klass.new(request).handle
      #
      #SlackInterface.new.handle_slack_webhook(request.body.read)
      event = params[:event]
      binding.pry

      command_text = event[:text].strip

      command = BubBot::Slack::CommandParser.get_command(command_text)

      puts "Running command #{command}"

      if command
        command.new(event.merge(command_text: command_text)).run
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
