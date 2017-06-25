require 'yaml'

class BubBot::CLI
  DEFAULT_CONFIG_FILENAME = 'bub_bot.yml'
  def initialize(args)
    @args = args

    @filename = args[0] || DEFAULT_CONFIG_FILENAME
  end

  def start
    print_usage && return unless check_usage

    configure_from_file(@filename)

    BubBot.start
  end

  private

  def configure_from_file(filename)
    file_data = YAML.load_file(filename)

    BubBot.configure do |config|
      BubBot::Configuration::OPTIONS.each do |option_name|
        config.public_send((option_name.to_s + '=').to_sym, file_data[option_name.to_s])
      end
    end
  end

  def check_usage
    @args.count <= 1
  end

  def print_usage
    puts <<USAGE
    Usage: bub_bot [config_filename]

    Default to #{DEFAULT_CONFIG_FILENAME} if config_filename is not provided
USAGE
  end
end
