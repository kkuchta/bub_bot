require 'action_view'
require 'action_view/helpers'

class BubBot::Slack::Command::List < BubBot::Slack::Command
  include ActionView::Helpers::DateHelper

  def self.aliases
    %w(list status all wazup)
  end

  def run
    list_strings = servers.list.map do |server, claim|
      if claim['expires_at']
        time_ago = time_ago_in_words(claim['expires_at'])
        "#{server}: *#{claim['user']}'s* for the next #{time_ago}"
      else
        "#{server}: *free*"
      end
    end

    respond(list_strings.join("\n"))
  end

  private

end
