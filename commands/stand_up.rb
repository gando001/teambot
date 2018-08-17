require_relative '../services/stand_up'

class Standup < SlackRubyBot::Commands::Base
  command 'stand up'
  command 'standup'

  help do
    title 'stand up'
    desc 'Let\'s you know when the next stand up is and who will be leading it'
    long_desc 'Randomly assigns a team member to lead the next stand up.'
  end

  def self.call(client, data, match)
    message = StandUp.new.call

    client.say(text: message, channel: data.channel)
  end
end