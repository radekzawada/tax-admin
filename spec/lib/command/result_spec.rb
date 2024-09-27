require "rails_helper"

RSpec.describe Command::Result do
  subject(:result) { described_class.new(component:, errors:, data:) }

  let(:component) { :command }
  let(:errors) { {} }
  let(:data) { {} }

  describe "#success?" do
    subject(:success) { result.success? }

    context "when there are no errors" do
      it "returns true" do
        expect(success).to be true
      end
    end

    context "when there are errors" do
      let(:errors) { { some_error: "error message" } }

      it "returns false" do
        expect(success).to be false
      end
    end
  end

  describe "#failure?" do
    subject(:failure) { result.failure? }

    context "when there are no errors" do
      it "returns false" do
        expect(failure).to be false
      end
    end

    context "when there are errors" do
      let(:errors) { { some_error: "error message" } }

      it "returns true" do
        expect(failure).to be true
      end
    end
  end

  describe "#to_monad" do
    subject(:to_monad) { result.to_monad }

    context "when there are no errors" do
      it "returns a Success monad with data" do
        expect(to_monad).to eq(Dry::Monads::Success(data))
      end
    end

    context "when there are errors" do
      let(:errors) { { some_error: "error message" } }

      it "returns a Failure monad with errors" do
        expect(to_monad).to eq(Dry::Monads::Failure(errors))
      end
    end
  end
end
