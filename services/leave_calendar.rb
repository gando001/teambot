require_relative '../constants'

class LeaveCalendar
  def initialize(calendar_api, stand_up_date)
    @calendar_api = calendar_api
    @stand_up_date = stand_up_date
  end

  def call
    leave_events if events?
  end

  private

  def events?
    calendar_events.items.any?
  end

  def leave_events
    events = calendar_events.items.collect { |event| "#{event.summary}\n" }

    "*Crew on leave:*\n#{events.join}"
  end

  def calendar_events
    @calendar_events ||= @calendar_api.list_events(
      CALENDAR,
      single_events: true,
      order_by: 'startTime',
      time_min: time_min,
      time_max: time_max
    )
  end

  def time_min
    @time_min ||= @stand_up_date.strftime('%Y-%m-%dT00:00:00%z')
  end

  def time_max
    @time_max ||= @stand_up_date.strftime('%Y-%m-%dT23:59:00%z')
  end
end