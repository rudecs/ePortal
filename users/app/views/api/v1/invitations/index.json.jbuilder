json.invitations @invitations do |invitation|
  json.partial! 'invitations/invitation.json', invitation: invitation
end
