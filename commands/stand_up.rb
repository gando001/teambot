require_relative '../services/stand_up'

module SlackRubyBot
  module Commands
    class Standup < Base
      command 'stand up'
      command 'standup'

      help do
        title 'stand up or standup'
        desc 'Let\'s you know when the next stand up is and who will be leading it'
      end

      def self.call(client, data, match)
        message = StandUp.new.call

        client.say(text: message, channel: data.channel)
      end
    end
  end
end