class Admin::MailboxController < ApplicationController
  layout "admin"
  before_action :authenticate_user!

  def index
    @presenter = Mailbox::Presenter.new
  end

  def create_template_file
    result = Mailbox::CreateMessageTemplate.default.call(request.parameters)

    if result.success?
      render json: { data: result.data }, status: :created
    elsif result.component == :contract
      render json: { errors: result.errors }, status: :unprocessable_entity
    else
      render json: { errors: result.errors }, status: :bad_request
    end
  end
end
