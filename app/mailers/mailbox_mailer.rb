class MailboxMailer < ApplicationMailer
  layout "mailer"

  def tax_information_message(draft_message)
    @draft_message = draft_message

    mail(to: draft_message.variables[:email], subject: I18n.t("mailers.mailbox.tax_information_message.subject"))
  end
end
