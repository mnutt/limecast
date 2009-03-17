module UsersHelper
  def create_user_error(user)
    forgot_password = link_to("I forgot my password", forgot_password_url)

    if user.errors[:login]
      return 'Choose your new user name.'                                if user.errors[:login].include?("is invalid") or user.errors[:login].include?("cannot be blank")
      return 'User name must be 3 characters or longer.'                if user.errors[:login].include?("is too short (minimum is 3 characters)")
      return "Sorry, this user name is taken.  Please pick another one." if user.errors[:login].include?("has already been taken")
    elsif user.errors[:password]
      return 'Please choose a password.'                                 if user.errors[:password].include?("can't be blank")
      return 'Password must be 4 characters or longer.'                  if user.errors[:password].include?("is too short (minimum is 4 characters)")
    elsif user.errors[:email]
      return "User and password don\\'t match. <br>#{forgot_password}" if user.errors[:email].include?("email and password don't match")
      return "This email is already signed up! <br>#{forgot_password}" if user.errors[:email].include?("has already been taken")
      return 'Please type your email address.'                           if user.errors[:email].include?("can't be blank") or user.errors[:email].include?("is invalid")
    end
  end

  def link_to_add_favorite(podcast)
    link_to 'Add to favorites', favorite_podcast_url(:podcast_slug => podcast.clean_url), :class => "favorite_link login", :rel => ".login_pop"
  end

  def link_to_remove_favorite(podcast)
    link_to 'Remove from favorites', favorite_podcast_url(:podcast_slug => podcast.clean_url), :class => "login", :rel => ".login_pop"
  end

  def link_to_favorites_page(user)
    link_to "Marked as favorite", user_url(user, :anchor => "profile_favorites"), :class => "calloutlight", :title => "Go to your favorites"
  end
end



