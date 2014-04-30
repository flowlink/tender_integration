require 'spec_helper'

describe TenderEndpoint do
  let(:error_notification_payload) do
    {
      "subject" => "Invalid China Order",
      "description" => "This order is shipping to China but was invalidly sent to PCH"
    }
  end

  let(:warning_notification_payload) do
    {
      "subject" => "Item out of stock",
      "description" => "This products requested in this order are not in stock."
    }
  end

  let(:info_notification_payload) do
    {
      "subject" => "Order Received",
      "description" => "You have received an order."
    }
  end

  let(:params) do
    {
      'tender_api_key' => 'foobar',
      'tender_domain' => 'spree-commerce-test',
      'tender_author_name' => 'Spree Integrator',
      'tender_author_email' => 'support@spreecommerce.com',
      'tender_category_id' => '77782',
      'tender_public' => 'false'
    }
  end

  context "when the tender domain is valid" do
    before(:each) do
      params.merge!('tender_domain' => 'spree-commerce-test')
    end

    it "should respond to POST error notification import" do
      error_notification_payload['parameters'] = params

      VCR.use_cassette('error_notification_import') do
        post '/import', error_notification_payload.to_json, auth
        last_response.status.should == 200
        last_response.body.should match "created at"
      end
    end

    it "should respond to POST warning notification import" do
      warning_notification_payload['parameters'] = params

      VCR.use_cassette('warning_notification_import') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 200
        last_response.body.should match "created at"
      end
    end
  end

  context "when the tender domain is invalid" do
    before(:each) { params.merge!('tender_domain'=> 'invaliddomain') }

    it "raises an error" do
      warning_notification_payload['parameters'] = params

      VCR.use_cassette('invalid_domain') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 500
        last_response.body.should =~ /ensure your Tender domain is correct/
      end
    end
  end

  context "when the api key is invalid" do
    before(:each) { params.merge!('tender_api_key' => 'invalidkey') }

    it "raises an error" do
      warning_notification_payload['parameters'] = params

      VCR.use_cassette('invalid_api_key') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 500
        last_response.body.should =~ /Invalid email\/password/
      end
    end
  end

  context "when the category id is invalid" do
    before(:each) { params.merge!('tender_category_id' => 'ccc') }

    it "raises an error" do
      warning_notification_payload['parameters'] = params

      VCR.use_cassette('invalid_category_id') do
        post '/import', warning_notification_payload.to_json, auth
        last_response.status.should == 500
        last_response.body.should =~ /can't be blank/
      end
    end
  end
end
