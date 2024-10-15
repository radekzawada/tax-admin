class MailboxMailer < ApplicationMailer
  # Temat: Informacja o podatkach

  # Dzień dobry,

  # Podatki za wskazany okres wyglądają następująco:

  # Rodzaj podatku: %rodzaj podatku np. PIT-36L, PIT-36, PIT-28%
  # Okres: %okres, np. "maj 2024" lub "3. kwartał"%
  # Termin płatności: %termin płatności, data%
  # Kwota: %kwota podatku%

  # %opcjonalnie%
  # Rodzaj podatku: VAT-7 lub VAT-7K
  # Okres: %okres, np. "maj 2024" lub "3. kwartał"%
  # Termin płatności: %termin płatności, data%
  # Kwota: %kwota podatku%

  # Numer konta do wpłaty (dla wszystkich podatków): %numer konta do wpłaty podatku%

  # W razie pytań prosimy o kontakt.

  # Z poważaniem,
  # %Twoje Biuro Rachunkowe%
  def tax_information_message(record)
    @message = message
    mail(to: @message.mailbox.email, subject: "You have a new message")
  end
end
