require 'date'
require 'digest'
require 'dotenv/load'

class StandUp
  ENV_TEAM_LIST = ENV['TEAM_MEMBERS']
  STAND_UP_TIME = { hour: 9, minute: 30 }

  def call
    raise "Missing team member list in .env file" unless ENV_TEAM_LIST
    raise "Team member list in .env file is empty" if ENV_TEAM_LIST.length.zero?

    "*Next Standup => #{stand_up_time}*\n<@#{select_user}> will be leading this stand up"
  end

  private

  def team_list
    @team_list ||= begin
      list = ENV_TEAM_LIST.split

      stand_up_date.day % 2 == 0 ? list : list.reverse
    end
  end

  def select_user
    hex = Digest::MD5.hexdigest(stand_up_date.to_s).to_i(16)
    selected_index = hex * stand_up_date.yday * stand_up_date.cwday % team_list.length

    team_list[selected_index]
  end

  def stand_up_date
    @stand_up_date ||= stand_up_for_today? ? Date.today : next_stand_up_date
  end

  def stand_up_time
    "#{stand_up_date.strftime('%A, %e %B')} #{STAND_UP_TIME[:hour]}:#{STAND_UP_TIME[:minute]}am"
  end

  def stand_up_for_today?
    current_hour = Time.now.hour

    current_hour <= STAND_UP_TIME[:hour] || current_hour == STAND_UP_TIME[:hour] && Time.now.min <= STAND_UP_TIME[:minute]
  end

  def next_stand_up_date
    Date.today.friday? ? Date.today + 3 : Date.today + 1
  end
end