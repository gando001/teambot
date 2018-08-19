require_relative '../services/google'

class GoogleCalendar < SlackRubyBot::Commands::Base
  command 'where is'

  help do
    title 'where is'
    desc 'Displays events from the given persons calendar'
    long_desc 'Looking for someone in your team? Use this command to find where their are now or what events they have today'
  end

  def self.call(client, data, match)
    message = Calendar.new(match[:expression]).call

    client.web_client.chat_postEphemeral(text: message, channel: data.channel, user: data.user)
  end
end