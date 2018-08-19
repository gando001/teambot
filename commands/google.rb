require_relative '../services/google'

class GoogleCalendar < SlackRubyBot::Commands::Base
  command 'where is'

  def self.call(client, data, match)
    message = Calendar.new(match[:expression]).call

    client.web_client.chat_postEphemeral(text: message, channel: data.channel, user: data.user)
  end
end