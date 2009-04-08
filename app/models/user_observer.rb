class UserObserver < ActiveRecord::Observer
  def after_save(user)
    if user.recently_confirmed?
      UserMailer.deliver_activation(user)
    elsif user.fresh? && user.unconfirmed?
      UserMailer.deliver_signup_notification(user)
    elsif user.email_changed? && user.unconfirmed?
      user.messages << "Please check your email for a note from us."
      UserMailer.deliver_reconfirm_notification(user)
    end
  end

  def before_save(user)
    user.unconfirm if user.state.blank?
  end

  def before_update(user)
    if user.email_changed? && !user.passive?
      user.unconfirm
    end
  end
end
