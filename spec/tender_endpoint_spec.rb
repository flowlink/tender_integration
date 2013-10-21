require 'spec_helper'

describe TenderEndpoint do
  def auth
    {'HTTP_X_AUGURY_TOKEN' => 'x123', "CONTENT_TYPE" => "application/json"}
  end

  def app
    described_class
  end

  let(:error_notification_payload) { { "message" => "notification:error", "message_id" => "518726r84910515003", "payload" => { "subject" => "Invalid China Order", "description" => "This order is shipping to China but was invalidly sent to PCH" } } }
  let(:warning_notification_payload) { { "message" => "notification:warn", "message_id" => "518726r84910515004", "payload" => { "subject" => "Item out of stock", "description" => "This products requested in this order are not in stock." } } }
  let(:info_notification_payload) { { "message" => "notification:info", "message_id" => "518726r84910515005", "payload" => { "subject" => "Order Received", "description" => "You have received an order." } } }

  let(:params) do
      [ { 'name' => 'tender.api_key', 'value' => 'foobar' },
      { 'name' => 'tender.domain', 'value' => 'spree-commerce-test' },
      { 'name' => 'tender.author_name', 'value' => 'Spree Integrator' },
      { 'name' => 'tender.author_email', 'value' => 'support@spreecommerce.com' },
      { 'name' => 'tender.category_id', 'value' => '77782' },
      { 'name' => 'tender.public', 'value' => 'false' } ]
  end

  context "when the tender domain is valid" do
    before(:each) { params.push({'name' => 'tender.domain', 'value' => 'spree-commerce-test'}) }

    it "should respond to POST error notification import" do
      error_notification_payload['payload']['parameters'] = params

      VCR.use_cassette('error_notification_import') do
        post '/import', error_notification_payload.to_json, auth
        last_response.status.should == 200
        last_response.body.should match /TenderApp Discussion Created/
      end
    end

    it "should respond to POST warning notification import" do
      warning_notification_payload['payload']['parameters'] = params

      VCR.use_cassette('warning_notification_import') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 200
        last_response.body.should match /TenderApp Discussion Created/
      end
    end
  end

  context "when the tender domain is invalid" do
    before(:each) { params.push({'name' => 'tender.domain', 'value' => 'invaliddomain'}) }

    it "raises an error" do
      warning_notification_payload['payload']['parameters'] = params

      VCR.use_cassette('invalid_domain') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 500
        last_response.body.should =~ /ensure your Tender domain is correct/
      end
    end
  end

  context "when the api key is invalid" do
    before(:each) { params.push({'name' => 'tender.api_key', 'value' => 'invalidkey'}) }

    it "raises an error" do
      warning_notification_payload['payload']['parameters'] = params

      VCR.use_cassette('invalid_api_key') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 500
        last_response.body.should =~ /Invalid email\/password/
      end
    end
  end

  context "when the category id is invalid" do
    before(:each) { params.push({'name' => 'tender.category_id', 'value' => 'ccc'}) }

    it "raises an error" do
      warning_notification_payload['payload']['parameters'] = params

      VCR.use_cassette('invalid_category_id') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 500
        last_response.body.should =~ /can't be blank/
      end
    end
  end
end
