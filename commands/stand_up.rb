require_relative '../services/stand_up_date'
require_relative '../services/stand_up'
require_relative '../services/leave_calendar'

class Standup < SlackRubyBot::Commands::Base
  command 'stand up'
  command 'standup'

  help do
    title 'stand up'
    desc 'Let\'s you know when the next stand up is and who will be leading it'
    long_desc 'Randomly assigns a team member to lead the next stand up.'
  end

  def self.call(client, data, match)
    stand_up_date = StandUpDate.new.call

    stand_up_message = StandUp.new(stand_up_date).call
    leave_message = LeaveCalendar.new(stand_up_date).call

    message = [stand_up_message, leave_message].join("\n\n")

    client.say(text: message, channel: data.channel)
  end
end