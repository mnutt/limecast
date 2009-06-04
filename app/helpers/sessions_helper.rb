module SessionsHelper
  # TODO refactor this; can we somehow move it somewhere where we can test it?
  def create_session_error(params)
    forgot_password = link_to("I forgot my password", forgot_password_url)
    signup          = link_to('Sign Up', '#', :class => 'inline_signup_button')

    if params[:user][:login].blank?
      return "Please type your username."
    elsif params[:user][:password].blank?
      return "Please type your password."
    elsif @unknown_email
      return "This email is new to us. Are you trying to #{signup}?"
    elsif @unknown_user
      return "Please type your email address."
    else
      return "User and password don't match. #{forgot_password}"
    end
  end
end

