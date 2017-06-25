require 'bub_bot/slack/command_parser'

class BubError < StandardError
end

class BubBot::WebServer
  def call(env)
    puts 'here'
    request = Rack::Request.new(env)

    # For easily checking if the server's up
    if request.path == '/' && request.get?
      return [200, {}, ['ok']]

    elsif request.path == '/slack_hook' && request.post?
      params = Rack::Utils
        .parse_nested_query(request.body.read)
        .with_indifferent_access
      # command = first_arg
      # klass = find_command_class(command)
      # klass.new(request).handle
      #
      #SlackInterface.new.handle_slack_webhook(request.body.read)

      # Strip off the 'bub'
      command_text = params['text']
        .sub(params['trigger_word'], '')
        .strip

      command = BubBot::Slack::CommandParser.get_command(command_text)

      puts "Running command #{command}"

      #command.new(params.merge(command_text: command_text)).run

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
end
