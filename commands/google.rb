require_relative '../services/google'

class GoogleCalendar < SlackRubyBot::Commands::Base
  command 'where is'

  def self.call(client, data, match)
    message = Calendar.new(match[:expression]).call

    # change to private message
    client.say(text: message, channel: data.channel)
  end
end