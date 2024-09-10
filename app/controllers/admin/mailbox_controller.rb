class Admin::MailboxController < ApplicationController
  layout "admin"
  before_action :authenticate_user!

  def index
    @presenter = Mailbox::Presenter.new
  end

  def create_template_file
  end
end
