class BubBot::Slack::Command
  def self.can_handle?(command)
    aliases.include?(command)
  end

  def self.aliases
    binding.pry
    puts 'here'
  end

  def initialize(options)
    puts "initialized a command"
  end

end
