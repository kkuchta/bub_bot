class BubBot::RackHandler
  def call(env)
    return [200, {}, ['foobar']]
  end
end
