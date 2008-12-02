module SessionsHelper
  def create_session_error(params)
    if params[:user][:login].blank?
      return '<p>Please type your username</p>'
    elsif @unknown_email
      return '<p>This email is new to us.  Are you trying to <a href="#" class="inline_signup_button">Sign Up</a>?'
    elsif @unknown_user
      return '<p>This user is new to us. Are you trying to <a href="#" class="inline_signup_button">Sign Up</a>?'
    elsif params[:user][:password].blank?
      return '<p>Please type your password</p>'
    else
      return '<p>User and password don\'t match. <%= link_to %{I forgot my password}, forgot_password_url -%></p>'
    end
  end
end



