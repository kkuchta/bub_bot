class BubError < StandardError
end

class BubBot::RackHandler
  def call(env)
    request = Rack::Request.new(env)

    if request.path == '/' && request.get?
      return [200, {}, ['ok']]
    elsif request.path == '/slack_hook' && request.post?
      #SlackInterface.new.handle_slack_webhook(request.body.read)
      puts "got request.body.read: #{request.body.read}"
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
end
