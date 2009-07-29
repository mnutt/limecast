module SessionsHelper
  # TODO refactor this; can we somehow move it somewhere where we can test it?
  def create_session_error(params)
    forgot_password = link_to("I forgot my password", forgot_password_url)

    if params[:user][:email].blank?
      return "Please type your email or login."
    elsif @unknown_user
      return "Please type your email address to signup."
    elsif @unknown_email
      return "This email is new to us. Are you trying to sign up?"
    elsif params[:user][:password].blank?
      return "Please type your password."
    else
      return "User and password don't match. #{forgot_password}"
    end
  end
end

