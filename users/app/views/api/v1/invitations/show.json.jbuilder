json.invitation do
  json.id          @invitation.id
  json.email       @invitation.email
  json.client_id   @invitation.client_id
  json.role_id     @invitation.role_id
  json.sender_id   @invitation.sender_id
  json.receiver_id @invitation.receiver_id
  json.created_at  @invitation.created_at

  json.client(@invitation.client, :id, :name)
  json.role(@invitation.role, :id, :name)
  json.sender(@invitation.sender, :id, :first_name, :last_name, :email)
  if @invitation.receiver.present?
    json.receiver(@invitation.receiver, :id, :first_name, :last_name, :email)
  end
end
