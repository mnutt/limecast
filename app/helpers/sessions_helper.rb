module SessionsHelper
  def create_session_error(params)
    if params[:user][:login].blank?
      return 'Please type your username'
    elsif @unknown_email
      return 'This email is new to us.  Are you trying to <a href="#" class="inline_signup_button">Sign Up</a>?'
    elsif @unknown_user
      return 'This user is new to us. Are you trying to <a href="#" class="inline_signup_button">Sign Up</a>?'
    elsif params[:user][:password].blank?
      return 'Please type your password'
    else
      return 'User and password don\'t match. <%= link_to %{I forgot my password}, forgot_password_url -%>'
    end
  end
end



