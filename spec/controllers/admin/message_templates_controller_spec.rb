require "rails_helper"

RSpec.describe Admin::MessageTemplatesController, type: :controller do
  describe "GET #show" do
    subject(:action) { get :show, params: { id: message_template.id } }

    let!(:message_template) { create(:message_template) }
    let(:user) { create(:user) }

    context "when user is authenticated" do
      before { sign_in(user) }

      specify do
        expect(action).to render_template(:show)

        expect(assigns(:presenter)).to be_a(MessageTemplates::ShowPresenter)
      end
    end

    context "when user is not authenticated" do
      it "requires user to be authenticated" do
        expect(action).to redirect_to(new_user_session_path)
      end
    end
  end
end
