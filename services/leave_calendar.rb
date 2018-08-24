require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class LeaveCalendar
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Teambot'.freeze
  CREDENTIALS_PATH = 'credentials.json'.freeze
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
  CALENDAR = 'xero.com_ubk9v43pto0ha50l0i6rvjjves@group.calendar.google.com'

  def initialize(date)
    @date = date
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
    @calendar_events ||= service.list_events(
      CALENDAR,
      single_events: true,
      order_by: 'startTime',
      time_min: time_min,
      time_max: time_max
    )
  end

  def time_min
    @time_min ||= @date.strftime('%Y-%m-%dT00:00:00%z')
  end

  def time_max
    @time_max ||= @date.strftime('%Y-%m-%dT23:59:00%z')
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