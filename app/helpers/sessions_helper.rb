module SessionsHelper
  def create_session_error(params)
    forgot_password = link_to("I forgot my password", forgot_password_url)
    signup          = link_to('Sign Up', '#', :class => 'inline_signup_button')

    if params[:user][:login].blank?
      return "Please type your username."
    elsif @unknown_email
      return "This email is new to us. Are you trying to #{signup}?"
    elsif @unknown_user
      return "This user is new to us. Are you trying to #{signup}?"
    elsif params[:user][:password].blank?
      return "Please type your password"
    else
      return "User and password don't match. #{forgot_password}"
    end
  end
end

