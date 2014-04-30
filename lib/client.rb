class Client
  attr_reader :client, :config, :payload

  def initialize(configuration, payload)
    @client = Tender::Client.new(configuration['tender_domain'], configuration['tender_api_key'])
    @config = configuration
    @payload = payload
  end

  def create_discussion
    discussion = client.create_discussion(config['tender_category_id'],
                                       public: config['tender_public'],
                                       author_name: config['tender_author_name'],
                                       author_email: config['tender_author_email'],
                                       title: payload['subject'],
                                       body: "@@@\n" + payload['description'] + "\n@@@"
                                      )
    discussion if validate_response(discussion)
  end

  private

  def validate_response(response)
    case response.status
    when 201
      true
    when 401
      raise ApiError, response.body
    when 404
      raise ApiError, "The request failed because the URL could not be found. Please ensure your Tender domain is correct."
    else
      raise ApiError, "An unknown error occured: #{response.body}"
    end
  end
end

class ApiError < StandardError; end
