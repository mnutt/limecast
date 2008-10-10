module UsersHelper
  def create_error(user)
    forgot_password = link_to("I forgot my password", forgot_password_url)

    if user.errors[:email]
      return "Email and password don\\'t match. #{forgot_password}"   if @user.errors[:email].include?("email and password don't match")
      return "This email is already signed up! #{forgot_password}" if @user.errors[:email].include?("has already been taken")
      return 'Please type your email address'                      if @user.errors[:email].include?("can't be blank") or @user.errors[:email].include?("is invalid")
    elsif @user.errors[:login]
      return 'Choose your new user name'                            if @user.errors[:login].include?("is invalid") or @user.errors[:login].include?("cannot be blank")
      return 'User names must be at least 3 characters'             if @user.errors[:login].include?("is too short (minimum is 3 characters)")
      return 'Sorry, this name is taken.  Please pick another one.' if @user.errors[:login].include?("has already been taken")
    elsif @user.errors[:password]
      return 'Please choose a password'       if @user.errors[:password].include?("can't be blank")
      return 'Please choose a valid password' if @user.errors[:password].include?("is too short (minimum is 3 characters)")
    end
  end
end
