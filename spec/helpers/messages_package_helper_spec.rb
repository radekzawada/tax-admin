require "rails_helper"

RSpec.describe MessagesPackageHelper, type: :helper do
  describe "#external_url" do
    subject(:external_url) { helper.external_url(template, package) }

    let(:template) { instance_double(MessageTemplate, url: "http://example.com/") }
    let(:package) { instance_double(MessagesPackage, external_sheet_id: "12345") }

    it "returns the correct external URL" do
      expect(helper.external_url(template, package)).to eq("http://example.com/#gid=12345")
    end
  end
end
