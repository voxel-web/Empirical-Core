class InvitationEmailWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    invitation = Invitation.find(invitation_id)
    email_vars = invitation.attributes
    email_vars[:inviter_name] = invitation.inviter.name
    email_vars[:classroom_names] = []
    email_vars[:coteacher_classroom_invitation_ids] = []
    invitation.coteacher_classroom_invitations.each do |ctc|
      email_vars[:classroom_names] << ctc.classroom.name
      email_vars[:coteacher_classroom_invitation_ids] << ctc.id
    end
    invitee_in_db = User.find_by(email: invitation.invitee_email)
    if invitee_in_db
      email_vars[:invitee_first_name] = invitee_in_db.first_name
      invitee_in_db.send_invitation_to_existing_user(email_vars)
    else
      invitation.inviter.send_invitation_to_non_existing_user(email_vars)
    end
  end


end
