require 'date'

require_relative '../constants'

class StandUpDate
  def call
    stand_up_for_today? ? Date.today : next_stand_up_date
  end

  private

  def stand_up_for_today?
    current_hour = Time.now.hour

    current_hour < STAND_UP_TIME[:hour] || current_hour == STAND_UP_TIME[:hour] && Time.now.min <= STAND_UP_TIME[:minute]
  end

  def next_stand_up_date
    Date.today.friday? ? Date.today + 3 : Date.today + 1
  end
end