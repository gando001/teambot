require 'date'
require 'digest'

require_relative '../constants'

class StandUp
  def initialize(stand_up_date)
    @stand_up_date = stand_up_date
  end

  def call
    raise "Missing team member list in .env file" unless ENV_TEAM_LIST
    raise "Team member list in .env file is empty" if ENV_TEAM_LIST.length.zero?

    "*Standup:*\n#{stand_up_time}\n<@#{select_user}> will be leading this stand up"
  end

  private

  def team_list
    @team_list ||= ENV_TEAM_LIST.split
  end

  def select_user
    hex = Digest::MD5.hexdigest(@stand_up_date.to_s).to_i(16)
    selected_index = hex % team_list.length

    team_list[selected_index]
  end

  def stand_up_time
    "#{@stand_up_date.strftime('%A')} #{STAND_UP_TIME[:hour]}:#{STAND_UP_TIME[:minute]}am"
  end
end