require 'slack-ruby-bot'
require 'date'
require 'digest'
require 'dotenv/load'

class TeamBot < SlackRubyBot::Bot
  command 'stand up', 'standup' do |client, data, match|
    message = "*Next Standup => #{stand_up_time}*\n<@#{select_user}> will be leading this stand up"

    client.say(text: message, channel: data.channel)
  end

  class << self
    TEAM_MEMBERS = {
      # INSERT EMAIL ADDRESS => USERID
    }.freeze
    STAND_UP_TIME = { hour: 9, minute: 30 }

    def select_user
      hex = Digest::MD5.hexdigest(stand_up_date.to_s).to_i(16)
      selected_index = hex.to_s.split('').slice(0,2).join.to_i % TEAM_MEMBERS.length

      TEAM_MEMBERS.to_a[selected_index].last
    end

    def stand_up_date
      @stand_up_date ||= has_stand_up_happened? ? Date.today : next_stand_up_date
    end

    def stand_up_time
      "#{stand_up_date.strftime('%A, %e %B')} #{STAND_UP_TIME[:hour]}:#{STAND_UP_TIME[:minute]}am"
    end

    def has_stand_up_happened?
      Time.now.hour < STAND_UP_TIME[:hour] && Time.now.min <= STAND_UP_TIME[:minute]
    end

    def next_stand_up_date
      Date.today.friday? ? Date.today + 3 : Date.today + 1
    end
  end
end

TeamBot.run