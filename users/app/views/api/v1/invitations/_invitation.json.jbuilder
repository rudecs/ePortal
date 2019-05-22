if invitation.present?
  json.(invitation, :id, :email, :client_id, :role_id, :sender_id, :receiver_id, :created_at)
  json.client(invitation.client, :id, :name)
  json.role(invitation.role, :id, :name)
  json.sender(invitation.sender, :id, :first_name, :last_name, :email)
  if invitation.receiver.present?
    json.receiver(invitation.receiver, :id, :first_name, :last_name, :email)
  end
end
