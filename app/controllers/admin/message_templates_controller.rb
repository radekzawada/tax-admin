class Admin::MessageTemplatesController < AdminController
  def show
    message_template = MessageTemplate.find(params[:id])

    @presenter = MessageTemplates::ShowPresenter.new(message_template)
  end
end
