require "rails_helper"

RSpec.describe Admin::MailboxController, type: :controller do
  describe "GET #index" do
    subject(:action) { get :index }

    let(:user) { create(:user) }

    context "when user is authenticated" do
      before { sign_in user }

      it "renders the index template" do
        action

        expect(response).to render_template(:index)
        expect(assigns(:presenter)).to be_a(Mailbox::Presenter)
      end
    end

    context "when user is not authenticated" do
      it "requires user to be authenticated" do
        action

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #create_template_file" do
    subject(:action) { post :create_template_file, params: }

    let(:user) { create(:user) }
    let(:params) { {} }

    context "when user is not authenticated" do
      it "redirects user to login page" do
        action

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      let(:params) do
        {
          name: "Test",
          sheet_name: "Sheet name",
          template: "taxes",
          emails: "test@email.com"
        }
      end

      before { sign_in user }

      it "creates a new template data container", :vcr do
        expect { action }.to change(TemplateDataContainer, :count).by(1)
          .and change(MessagePackage, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(TemplateDataContainer.last).to have_attributes(
          name: "Test",
          template_name: "taxes",
          permitted_emails: [ "test@email.com" ],
          url: start_with("https://docs.google.com/spreadsheets/d/"),
          external_spreadsheet_id: be_present
        )
        expect(MessagePackage.last).to have_attributes(
          status: "active",
          name: "Sheet name"
        )
      end
    end
  end
end
