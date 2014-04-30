require "sinatra"
require "endpoint_base"

require_relative './lib/client'

class TenderEndpoint < EndpointBase::Sinatra::Base
  endpoint_key ENV["ENDPOINT_KEY"]

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end

  set :logging, true

  post '/create_ticket' do
    begin
      discussion = Client.new(@config, @payload).create_discussion

      code = 200
      msg = "New TenderApp discussion '#{discussion.body['title']}' created at #{discussion.body['html_href']}."
    rescue Exception => e
      log_exception(e)
      code = 500
      msg = e.message
    end

    result code, msg
  end
end
