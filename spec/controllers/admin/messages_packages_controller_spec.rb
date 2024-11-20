require "rails_helper"

RSpec.describe Admin::MessagesPackagesController, type: :controller do
  describe "POST #create" do
    subject(:action) { post :create, params: }

    let(:user) { create(:user) }
    let(:params) { { message_template_id: 1 } }

    context "when user is authenticated" do
      let(:params) { { name: "sheet", message_template_id: template.id } }
      let(:template) do
         create(
          :message_template,
          template_name: "taxes",
          external_spreadsheet_id: "1HwTHd84ImjKoPVi5l7o1q0uveL-CSxVB5LraHhRZmCE"
        )
      end

      before { sign_in user }

      it "creates new messages package", :vcr do
        expect { action }.to change(MessagesPackage, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(MessagesPackage.last).to have_attributes(
          name: "sheet",
          message_template_id: template.id,
          external_sheet_id: be_present,
          status: "active"
        )
      end
    end

    context "when user is not authenticated" do
      it "requires user to be authenticated" do
        expect(action).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #draft_messages" do
    subject(:action) { get :draft_messages, params: }

    let(:user) { create(:user) }
    let(:params) { { id: 1, message_template_id: 1 } }

    context "when user is authenticated" do
      let(:params) { { id: messages_package.id, message_template_id: messages_package.message_template.id, fresh: } }
      let(:fresh) { false }

      let(:messages_package) { create(:messages_package, message_template:, name: "Październik 2024") }
      let(:message_template) do
        create(:message_template, external_spreadsheet_id: "1W-O7jpHkLmrijuYA0K4xgzwjcYttIx1zZIKkS0b_080")
      end

      before do
        sign_in user

        Redis.current.flushdb
      end

      it "fetches remote data", :vcr do
        expect(action).to render_template(:draft_messages)

        expect(assigns(:presenter)).to be_a(Mailbox::MessagesPackages::DraftPresenter)
      end
    end

    context "when user is not authenticated" do
      it "requires user to be authenticated" do
        expect(action).to redirect_to(new_user_session_path)
      end
    end
  end
end
