class UserMailer < ActionMailer::Base
  FROM_HOST = "podcasts.limewire.com"

  def signup_notification(user)
    setup_email(user)
    subject     'Please activate your new account'

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
