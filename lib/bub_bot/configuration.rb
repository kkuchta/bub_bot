# TODO: merge with some defaults
class BubBot::Configuration
  # Any of these options will be passed on to rack, rather than handled by us.
  RACK_OPTIONS = %i(
    Port
  )

  # These options will be handled by us.
  BUB_BOT_OPTIONS = %i(
    servers
    bot_oauth_token
    bot_name
    deploy_targets
    slack_channel
    redis_host
  )

  OPTIONS = RACK_OPTIONS + BUB_BOT_OPTIONS

  attr_accessor *OPTIONS

  def rack_options_hash
    RACK_OPTIONS.each_with_object({}) do |option_name, options_hash|
      options_hash[option_name] = public_send(option_name)
    end
  end

  def verify_options
    # TODO: verify that deploy_targets, etc, are formatted correctly and print
    # useful error messages otherwise.
    true
  end

end
