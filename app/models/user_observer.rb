class UserObserver < ActiveRecord::Observer
  def after_save(user)
    UserMailer.deliver_activation(user) if user.recently_activated?
  end

  def before_update(user)
    if user.email_changed? && !user.new_record? && !user.passive?
      user.make_pending
    end
  end
end
