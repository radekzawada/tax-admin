require "rails_helper"

RSpec.describe Google::DriveClient do
  describe ".default" do
    subject(:default) { described_class.default }

    it "returns an instance of Google::DriveClient" do
      expect(default).to be_an_instance_of(described_class) & have_attributes(
        google_drive_service: an_instance_of(Google::Apis::DriveV3::DriveService)
      )
    end
  end

  describe "#grant_permissions" do
    subject(:grant_permissions) { drive_client.grant_permissions(google_object_id, email:, role:, type:) }

    let(:drive_client) { described_class.new(google_drive_service:) }
    let(:google_drive_service) { instance_double(Google::Apis::DriveV3::DriveService) }

    let(:google_object_id) { "123" }
    let(:email) { "email@sample.test"  }
    let(:role) { described_class::WRITE_ROLE }
    let(:type) { described_class::USER_TYPE }

    before do
      allow(drive_client).to receive(:google_drive_service).and_return(google_drive_service)
    end

    specify do
      expect(grant_permissions).to be_success

      expect(google_drive_service).to have_received(:create_permission).with(
          google_object_id,
          an_instance_of(Google::Apis::DriveV3::Permission) & have_attributes(
            email_address: email,
            type:,
            role:
          )
        )
    end
  end
end
