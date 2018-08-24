require_relative '../constants'

class WhereIs
  def initialize(calendar_api, expression)
    @calendar_api = calendar_api
    @expression = expression
  end

  def call
    if unknown_command?
      usage_message
    elsif no_events?
      no_events_message
    else
      process_calendar_events
    end
  end

  private

  def unknown_command?
    @expression.nil? || person.nil?
  end

  def usage_message
    "Usage: where is @name _today_"
  end

  def no_events?
    calendar_events.items.empty?
  end

  def no_events_message
    today? ? "#{slack_user_name} has no meetings today" : "#{slack_user_name} is available, there is nothing scheduled in their calendar"
  end

  def process_calendar_events
    events = calendar_events.items.collect do |event|
      start_date = event.start.date || event.start.date_time
      end_date = event.end.date || event.end.date_time
      summary = event.summary || "private"

      start_date = start_date.strftime('%H:%M')
      end_date = end_date.strftime('%H:%M')

      "#{start_date} - #{end_date} #{summary}\n"
    end

    "```#{events.join}```"
  end

  def calendar_events
    @calendar_events ||= @calendar_api.list_events(
      person,
      single_events: true,
      order_by: 'startTime',
      time_min: time_min,
      time_max: time_max
    )
  end

  def person
    @person ||= ENV[slack_id]
  end

  def slack_id
    @slack_id ||= begin
      name = @expression.split(' ').first
      name[2..-2]
    end
  end

  def slack_user_name
    @slack_user_name ||= "<@#{slack_id}>"
  end

  def today?
    @expression.split(' ').length == 2
  end

  def time_min
    @time_min ||= begin
      if today?
        Time.now.strftime('%Y-%m-%dT00:00:00%z')
      else
        Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
      end
    end
  end

  def time_max
    @time_max ||= begin
      if today?
        Time.now.strftime('%Y-%m-%dT23:59:00%z')
      else
        (Time.now + 60).strftime('%Y-%m-%dT%H:%M:%S%z') # add 60 seconds
      end
    end
  end
end