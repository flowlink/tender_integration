require "sinatra"
require "endpoint_base"

require_relative './lib/client'

class TenderEndpoint < EndpointBase::Sinatra::Base
  post '/import' do
    begin
      client = Client.new(@config, @message[:message], @message[:payload])
      discussion = client.import
      code = 200
      result = { "message_id" => @message[:message_id], "notifications" => [ { "level" => "info",
        "subject" => "TenderApp Discussion Created", "description" => "New TenderApp discussion '#{discussion.body['title']}' created at #{discussion.body['html_href']}." } ] }
    rescue Exception => e
      code = 500
      result = { "error" => e.message, "trace" => e.backtrace.inspect }
    end
    process_result code, result
  end
end
