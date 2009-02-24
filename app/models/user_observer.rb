class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user) unless user.active? || user.passive?
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.recently_activated?
  end

  def before_update(user)
    if user.active? && user.email_changed?
      user.change_email!
      user.messages << "Please check your email for a note from us."
      UserMailer.deliver_reconfirm_notification(user)
    end
  end
end
