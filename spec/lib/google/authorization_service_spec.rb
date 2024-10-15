require "rails_helper"

RSpec.describe Google::AuthorizationService, type: :service do
  describe ".default" do
    subject(:default) { described_class.default }

    it "returns an instance of Google::AuthorizationService" do
      expect(default).to be_an_instance_of(described_class)
    end
  end

  describe "#authorization" do
    subject(:authorization) { service.authorization }

    let(:service) { described_class.new(google_auth:) }

    let(:google_auth) { class_double(Google::Auth::ServiceAccountCredentials) }
    let(:authorization_obj) { instance_double(Google::Auth::ServiceAccountCredentials) }
    let(:credentials_file) { instance_double(File) }

    before do
      allow(google_auth).to receive(:make_creds).and_return(authorization_obj)
      allow(File).to receive(:open).and_return(credentials_file)
    end

    specify do
      expect(service.authorization).to eq(authorization_obj)

      expect(google_auth).to have_received(:make_creds).with(
        json_key_io: credentials_file,
        scope: [Google::Apis::SheetsV4::AUTH_SPREADSHEETS, Google::Apis::DriveV3::AUTH_DRIVE]
      )
    end
  end
end
