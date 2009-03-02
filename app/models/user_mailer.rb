class UserMailer < ActionMailer::Base
  FROM_HOST = "limecast.com"

  # The Welcome email
  def signup_notification(user)
    setup_email(user)
    subject     'Welcome to LimeCast!'

    body :user => user, :host => FROM_HOST
  end

  # The Change Email email
  def reconfirm_notification(user)
    setup_email(user)
    subject     'Confirm new email'
    
    body :user => user, :host => FROM_HOST
  end

  # Successful Activation email
  def activation(user)
    setup_email(user)
    subject       'Your account has been activated!'
    body :user => user, :host => FROM_HOST
  end

  # The Forgot Password email
  def reset_password(user)
    setup_email(user)
    subject    "Password reset link"

    body :user => user, :host => FROM_HOST
  end

  # Essentially same as Forgot Password, but with different wording
  def claim_account(user)
    setup_email(user)
    subject    "Claim your podcasts on LimeCast"

    body :user => user, :host => FROM_HOST
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "LimeCast <podcasts@limewire.com>"
      @sent_on     = Time.now
    end
end
