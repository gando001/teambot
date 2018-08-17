require 'slack-ruby-bot'

require_relative 'commands'

class TeamBot < SlackRubyBot::Bot
  help do
    title 'Team Bot'
    desc 'This bot provides utilities to help your team'
  end
end

TeamBot.run