require 'slack-ruby-bot'

require_relative 'services/stand_up'

class TeamBot < SlackRubyBot::Bot
  help do
    title 'Team Bot'
    desc 'This bot provides utilities to help your team'

    command 'stand up' do
      desc 'Let\'s you know when the next stand up is and who will be leading it'
      long_desc 'Randomly assigns a team member to lead the next stand up.\nNote you can use _stand up_ or _standup_'
    end
  end

  command 'stand up', 'standup' do |client, data, match|
    message = StandUp.new.call

    client.say(text: message, channel: data.channel)
  end
end

TeamBot.run