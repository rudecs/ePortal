class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notify.subject
  #
  def notify(notification)
    @notification = notification
    n_request = @notification.notifications_request

    from =
      if n_request.key_name&.starts_with?('invitation')
        "#{n_request.provided_data[:sender_email]} via #{self.class.default[:from]}"
      elsif n_request.key_name&.starts_with?('arena_db_order')
        ['DigitalEnergy', self.class.default[:from]&.split(' ')&.last].join(' ')
      else
        self.class.default[:from]
      end

    # REVIEW: inv existing user, get his locale? use current user's locale?
    mail(
      # REVIEW: kostili
      # from: n_request.key_name&.starts_with?('invitation') ? "#{n_request.provided_data[:sender_email]} via #{self.class.default[:from]}" : self.class.default[:from],
      from: from,
      to: @notification&.destination,
      subject: @notification&.template&.subject || 'Fallback subject'
    ) # In case of manual request: || handle in locales with fallback
  end
end
