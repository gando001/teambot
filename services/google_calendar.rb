require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'date'
require 'dotenv/load'

class GoogleCalendar
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Teambot'.freeze
  CREDENTIALS_PATH = 'credentials.json'.freeze
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  def initialize(expression)
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
    today? ? "#{slack_user_name} has no meetings today" : "#{slack_user_name} should be available, there is nothing scheduled in their calendar"
  end

  def process_calendar_events
    events = calendar_events.items.collect do |event|
      start_date = event.start.date || event.start.date_time
      end_date = event.end.date || event.end.date_time
      summary = event.summary || "private"

      start_date = start_date.strftime('%I:%M')
      end_date = end_date.strftime('%I:%M')

      "#{start_date} - #{end_date} #{summary}\n"
    end

    "```#{events.join}```"
  end

  def calendar_events
    @calendar_events ||= service.list_events(
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
        Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
      end
    end
  end

  def service
    @service ||= initialize_api
  end

  def initialize_api
    Google::Apis::CalendarV3::CalendarService.new.tap do |service|
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
    end
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
          "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end
end