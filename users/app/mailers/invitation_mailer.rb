class InvitationMailer < ApplicationMailer
  def invite(invitation, sender)
    @invitation = invitation
    @sender = sender
    # TODO: use decorator
    @from = @sender.first_name.present? || @sender.last_name.present? ? [@sender.first_name&.upcase_first, @sender.last_name&.upcase_first].join(' ') : @sender.email
    locale = @sender.try(:locale) || I18n.default_locale

    I18n.with_locale(locale) do
      mail(
        from: "#{@from} (via PortalName) <#{self.class.default[:from]}>",
        to: @invitation.email,
        subject: I18n.t('invitation_mailer.invite.subject')
      )
    end
  end
end
