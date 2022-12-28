# Preview all emails at http://localhost:3000/rails/mailers/proposal_mailer
class ProposalMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/proposal_mailer/email_new_proposal
  def email_new_proposal
    ProposalMailer.email_new_proposal
  end

  # Preview this email at http://localhost:3000/rails/mailers/proposal_mailer/email_approved_proposal
  def email_approved_proposal
    ProposalMailer.email_approved_proposal
  end

  # Preview this email at http://localhost:3000/rails/mailers/proposal_mailer/email_not_approved_proposal
  def email_not_approved_proposal
    ProposalMailer.email_not_approved_proposal
  end

end
