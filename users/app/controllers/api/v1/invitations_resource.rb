class API::V1::InvitationsResource < API::V1
  # helpers API::V1::Helpers

  resource :invitations, desc: 'Управление приглашениями пользователя' do

    helpers do
    end

    desc 'Список приглашений пользователя'
    params do
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'invitations/index.json' do
      authenticate!
      @invitations = Invitation.pending.actual.where(receiver_id: current_user['id']).includes(:client, :role, :sender, :receiver)
    end

    desc 'Принять приглашение'
    params do
    end
    post ':id/accept' do
      authenticate!
      # TODO: scopes actual? pending?
      @invitation = Invitation.pending.actual.find_by!(id: params[:id], receiver_id: current_user['id'])
      error_422!(@invitation.errors) unless @invitation.accepted!
      {}
    end

    desc 'Отклонить приглашение'
    params do
    end
    post ':id/reject' do
      authenticate!
      @invitation = Invitation.pending.actual.find_by!(id: params[:id], receiver_id: current_user['id'])
      error_422!(@invitation.errors) unless @invitation.rejected!
      {}
    end
  end
end
