require "sinatra"
require "endpoint_base"

require_relative './lib/client'

class TenderEndpoint < EndpointBase::Sinatra::Base
  endpoint_key ENV["ENDPOINT_KEY"]

  post '/create_ticket' do
    begin
      discussion = Client.new(@config, @payload).create_discussion

      code = 200
      msg = "New TenderApp discussion '#{discussion.body['title']}' created at #{discussion.body['html_href']}."
    rescue Exception => e
      code = 500
      msg = e.message
    end

    result code, msg
  end
end
