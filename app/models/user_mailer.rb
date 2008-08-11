class UserMailer < ActionMailer::Base
  def signup_notification(user, host)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    body :user => user, :host => host
  end
  
  def activation(user, host)
    setup_email(user)
    @subject       'Your account has been activated!'
    body :user => user, :host => host
  end

  def reset_password(user, host)
    setup_email(user)
    subject    "LimeWire Podcast Directory Reset Password"

    body :user => user, :host => host
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "LimeWire Podcast Directory <podcasts@limewire.com>"
      @sent_on     = Time.now
    end
end
