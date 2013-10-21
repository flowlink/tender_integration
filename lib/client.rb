class Client
  attr_reader :client, :config, :message, :payload

  def initialize(configuration, message, payload)
    @client = Tender::Client.new(configuration['tender.domain'], configuration['tender.api_key'])
    @config = configuration
    @message = message
    @payload = payload
  end

  def import
    create_discussion
  end

  def create_discussion
    discussion = client.create_discussion(config['tender.category_id'],
                                       public: config['tender.public'],
                                       author_name: config['tender.author_name'],
                                       author_email: config['tender.author_email'],
                                       title: payload['subject'],
                                       body: payload['description']
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
