class InternalMailer < ApplicationMailer
  def arena_db(nr)
    @nr = nr

    mail(
      to: Rails.application.secrets.arena_db_emails,
      subject: 'Лендинг. Новая заявка облачной аналитической СУБД Arenadata DB.'
    )
  end
end
