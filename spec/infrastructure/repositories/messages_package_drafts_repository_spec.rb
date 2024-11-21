require "rails_helper"

RSpec.describe Repositories::MessagesPackageDraftsRepository do
  describe ".default" do
    subject(:default) { described_class.default }

    it "returns instance of the repository" do
      expect(default).to be_an_instance_of(described_class) & have_attributes(
        google_sheet_client: Google::SheetClient.default,
        redis_client: Redis.current,
        package_drafts_factory: Mailbox::Factories::MessagesPackageDraftsFactory.default
      )
    end
  end

  describe "#find" do
    subject(:find) { repository.find(id, fresh:) }

    let(:repository) { described_class.new(google_sheet_client:, redis_client:, package_drafts_factory:) }
    let(:google_sheet_client) { instance_double(Google::SheetClient) }
    let(:redis_client) { instance_double(Redis) }
    let(:package_drafts_factory) { instance_double(Mailbox::Factories::MessagesPackageDraftsFactory) }

    let(:id) { 1 }
    let(:fresh) { nil }

    context "when draft is found in redis" do
      let(:draft) do
        {
          package_id: 1,
          package_name: "message package 1",
          template_name: "message template name",
          template_id: 2,
          draft_messages: [],
          external_url: "www.example.com#gid=sheet_id",
          variables: %w[first_name last_name],
          mailer_message: :mailer_message
        }
      end

      before do
        allow(redis_client).to receive_messages(exists?: true, get: draft.to_json)
      end

      it "returns draft from redis" do
        expect(find).to be_success & have_attributes(
          value!: {
            data: an_instance_of(Mailbox::MessagesPackageDraft) & have_attributes(package_id: 1)
          }
        )
      end
    end

    context "when draft is not found in redis" do
      let(:messages_package) do
        instance_double(MessagesPackage, external_spreadsheet_id: "spreadsheet_id", range: "range")
      end
      let(:remote_data) { OpenStruct.new(values: [%w[John Doe], %w[Jane Smith]]) }

      let(:draft) do
        { package_id: 1, package_name: "message package 1", template_name: "message template name" }
      end

      before do
        allow(redis_client).to receive_messages(exists?: false, set: nil)
        allow(MessagesPackage).to receive_messages(includes: MessagesPackage, find_by: messages_package)

        allow(google_sheet_client).to receive(:read_data).and_return(Dry::Monads::Success(remote_data))
        allow(package_drafts_factory).to receive(:from_remote_data).and_return(draft)
      end

      it "returns draft from remote data and cache it in redis" do
        expect(find).to be_success & have_attributes(
          value!: { data: draft }
        )

        expect(redis_client).to have_received(:exists?).with("MESSAGES_PACKAGE_PREVIEW:1")
        expect(google_sheet_client).to have_received(:read_data).with("spreadsheet_id", "range")
        expect(package_drafts_factory).to have_received(:from_remote_data).with(remote_data.values, messages_package)
        expect(redis_client).to have_received(:set)
          .with("MESSAGES_PACKAGE_PREVIEW:1", draft.to_json, ex: 1.day.in_seconds)
      end
    end

    context "when messages_package does not exist" do
      before do
        allow(redis_client).to receive_messages(exists?: false)
        allow(MessagesPackage).to receive_messages(includes: MessagesPackage, find_by: nil)
      end

      it "returns failure" do
        expect(find).to be_failure & have_attributes(failure: :not_found)
      end
    end

    context "when fresh data are requested" do
      let(:fresh) { true }

      let(:messages_package) do
        instance_double(MessagesPackage, external_spreadsheet_id: "spreadsheet_id", range: "range")
      end
      let(:remote_data) { OpenStruct.new(values: [%w[John Doe], %w[Jane Smith]]) }

      let(:draft) do
        { package_id: 1, package_name: "message package 1", template_name: "message template name" }
      end

      before do
        allow(MessagesPackage).to receive_messages(includes: MessagesPackage, find_by: messages_package)

        allow(google_sheet_client).to receive(:read_data).and_return(Dry::Monads::Success(remote_data))
        allow(package_drafts_factory).to receive(:from_remote_data).and_return(draft)
        allow(redis_client).to receive(:set)
      end

      it "returns draft from remote data and cache it in redis" do
        expect(find).to be_success & have_attributes(
          value!: { data: draft }
        )

        expect(google_sheet_client).to have_received(:read_data).with("spreadsheet_id", "range")
        expect(package_drafts_factory).to have_received(:from_remote_data).with(remote_data.values, messages_package)
        expect(redis_client).to have_received(:set)
          .with("MESSAGES_PACKAGE_PREVIEW:1", draft.to_json, ex: 1.day.in_seconds)
      end
    end
  end
end
