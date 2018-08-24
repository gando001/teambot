require_relative '../services/calendar_api'
require_relative '../services/where_is'

class Whereis < SlackRubyBot::Commands::Base
  command 'where is'

  help do
    title 'where is'
    desc 'Displays events from the given persons calendar'
    long_desc 'Looking for someone in your team? Use this command to find where their are now or what events they have today'
  end

  def self.call(client, data, match)
    calendar_api = CalendarApi.new.call
    message = WhereIs.new(calendar_api, match[:expression]).call

    client.web_client.chat_postEphemeral(text: message, channel: data.channel, user: data.user)
  end
end