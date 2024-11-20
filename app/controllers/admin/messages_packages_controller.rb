class Admin::MessagesPackagesController < AdminController
  def create
    result = MessagesPackages::Create.default.call(request.parameters)

    if result.success?
      render json: { data: result.data }, status: :created
    elsif result.component == :contract
      render json: { errors: result.errors }, status: :unprocessable_entity
    else
      render json: { errors: result.errors }, status: :bad_request
    end
  end

  def draft_messages
    result = Repositories::MessagesPackageDraftsRepository.default
      .find(params[:id], fresh: params[:reload_data].present?)

    if result.success?
      @presenter = Mailbox::MessagesPackages::DraftPresenter.new(result.value![:data])
    else
      redirect_to(
        admin_message_template_url(params[:message_template_id]),
        alert: t("admin.mailbox.messages_packages.drafts.errors.#{result.failure}")
      )
    end
  end
end
