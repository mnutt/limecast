class UserMailer < ActionMailer::Base
  FROM_HOST = "limecast.com"

  def signup_notification(user)
    setup_email(user)
    subject     'Welcome to LimeCast!'

    body :user => user, :host => FROM_HOST
  end

  def reconfirm_notification(user)
    setup_email(user)
    subject     'Please reconfirm your email address'
    
    body :user => user, :host => FROM_HOST
  end

  def activation(user)
    setup_email(user)
    subject       'Your account has been activated!'
    body :user => user, :host => FROM_HOST
  end

  def reset_password(user)
    setup_email(user)
    subject    "LimeCast Reset Password"

    body :user => user, :host => FROM_HOST
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "LimeCast <podcasts@limewire.com>"
      @sent_on     = Time.now
    end
end
