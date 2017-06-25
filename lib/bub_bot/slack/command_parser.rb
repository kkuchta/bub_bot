module BubBot::Slack
end

require 'bub_bot/slack/command'
Dir[File.dirname(__FILE__) + '/commands/*.rb'].each {|file| require file }

class BubBot::Slack::CommandParser
  def self.get_command(string_input)
    puts "Parsing #{stringInput}"
    puts "options: #{command_classes}"
    command = string_input.split(' ').first

    if command
      command_classes.each do |command_class|
        command_class.can_handle?(command)
      end
    else

    end
  end

  def self.command_classes

    # Get all the classes under BubBot::Slack::Command::*
    @_command_classes ||= BubBot::Slack::Command.constants.map do |constant|
      (BubBot::Slack::Command.to_s + "::" + constant.to_s).safe_constantize
    end.select do |constant|

      # Get only the constants that are classes and inherit from Command
      constant.is_a?(Class) && constant < BubBot::Slack::Command
    end
  end
end
