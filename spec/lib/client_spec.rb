require 'spec_helper'

describe Client do
  let(:configuration) do
    {
      'tender.api_key'      => 'foobar',
      'tender.domain'       => 'spree-commerce-test',
      'tender.author_name'  => 'Spree Integrator',
      'tender.author_email' => 'hub@spreecommerce.com',
      'tender.category_id'  => '77782',
      'tender.public'       => 'false'
    }
  end
  let(:message) { { "message" => "notification:error", "message_id" => "518726r84910515003", "payload" => { "subject" => "Invalid China Order", "description" => "This order is shipping to China but was invalidly sent to PCH" } } }

  subject do
    Client.new(configuration, message['message'], message['payload'])
  end

  describe "#import" do
    it "should call create_dicussion" do
      Client.any_instance.should_receive(:create_discussion)
      subject.import
    end

    it "returns the newly created discussion" do
      VCR.use_cassette('create_discussion') do
        discussion = subject.import
        discussion.body['title'].should == message['payload']['subject']
        discussion.status.should == 201
      end
    end
  end

  describe "#create_discussion" do
    it "raises an ApiError if the response is not valid" do
      configuration['tender.api_key'] = 'invalidkey'
      VCR.use_cassette('invalid_create_discussion') do
        lambda { subject.create_discussion }.should raise_error(ApiError)
      end
    end

    it "returns the newly created discussion if the response is valid" do
      VCR.use_cassette('create_discussion') do
        discussion = subject.create_discussion
        discussion.body['title'].should == message['payload']['subject']
        discussion.status.should == 201
      end
    end
  end
end
