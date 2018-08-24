require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'dotenv/load'

ENV_TEAM_LIST = ENV['TEAM_MEMBERS']

STAND_UP_TIME = { hour: 9, minute: 30 }

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Teambot'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

CALENDAR = 'xero.com_ubk9v43pto0ha50l0i6rvjjves@group.calendar.google.com'