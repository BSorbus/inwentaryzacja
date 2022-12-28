require 'test_helper'

class ProposalMailerTest < ActionMailer::TestCase
  test "email_new_proposal" do
    mail = ProposalMailer.email_new_proposal
    assert_equal "Email new proposal", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "email_approved_proposal" do
    mail = ProposalMailer.email_approved_proposal
    assert_equal "Email approved proposal", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "email_not_approved_proposal" do
    mail = ProposalMailer.email_not_approved_proposal
    assert_equal "Email not approved proposal", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
