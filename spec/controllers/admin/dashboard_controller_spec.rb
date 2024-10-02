require "rails_helper"

RSpec.describe Admin::DashboardController, type: :controller do
  describe "GET #index" do
    subject(:action) { get :index }

    let(:user) { create(:user) }

    context "when user is authenticated" do
      before { sign_in user }

      it "renders the index template" do
        action

        expect(response).to render_template(:index)
      end
    end

    context "when user is not authenticated" do
      it "requires user to be authenticated" do
        action

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
