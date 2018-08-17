require 'slack-ruby-bot'

require_relative 'services/stand_up'

class TeamBot < SlackRubyBot::Bot
  help do
    title 'Team Bot'
    desc 'This bot provides utilities to help your team'

    command 'stand up' do
      desc 'Let\'s you know when the next stand up is and who will be leading it'
      long_desc 'Randomly assigns a team member to lead the next stand up.'
    end

    command 'standup' do
      desc 'Let\'s you know when the next stand up is and who will be leading it'
      long_desc 'Randomly assigns a team member to lead the next stand up.'
    end
  end

  command 'stand up', 'standup' do |client, data, match|
    message = StandUp.new.call

    client.say(text: message, channel: data.channel)
  end
end

TeamBot.run