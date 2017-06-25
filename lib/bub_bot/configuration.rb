class BubBot::Configuration
  RACK_OPTIONS = %i(
    Port
  )

  BUB_BOT_OPTIONS = %i(
    slack_token
    slack_url
  )

  OPTIONS = RACK_OPTIONS + BUB_BOT_OPTIONS

  attr_accessor *OPTIONS

  def rack_options_hash
    RACK_OPTIONS.each_with_object({}) do |option_name, options_hash|
      options_hash[option_name] = public_send(option_name)
    end
  end

end
