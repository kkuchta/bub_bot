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

  attr_writer *OPTIONS

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

  # Each config option will, when requested (eg BubBot.configuration.bot_name), be
  # run through ERB.  You can provide optional additional context for the erb call.
  # This is is a good way to provide variable that you want to access in the yaml.
  # Eg if the bot_name is "friendly_bot_<%= phase_of_moon %>" in the yaml, you could
  # call `BubBot.configuration.bot_name(phase_of_moon: 'waxing')`.
  OPTIONS.each do |option|
    define_method(option) do |extra_context = {}|
      option_data = instance_variable_get("@#{option}".to_sym)
      interpolate(option_data, extra_context)
    end
  end

  private

  def interpolate(data, extra_context)
    if data.is_a?(String)
      ERB.new(data).result(get_binding(extra_context))
    elsif data.is_a?(Array)
      data.map { |element| interpolate(element, extra_context) }
    elsif data.is_a?(Hash)
      data.each_with_object({}) do |(key, value), new_hash|
        new_hash[key] = interpolate(value, extra_context)
      end
    else
      data
    end
  end

  # Gets a binding object with the given variables defined in it.  You'd *think*
  # there'd be a simpler way.  Well, ok, there is, but there's no simpler way that
  # doesn't *also* polute the binding with variables from the outer scope.
  def get_binding(variables)
    obj = Class.new {
      attr_accessor *variables.keys
      def get_binding(); binding end
    }.new
    variables.each { |name, value| obj.public_send(:"#{name}=", value) }
    obj.get_binding
  end
end
