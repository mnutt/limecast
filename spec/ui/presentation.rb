require File.dirname(__FILE__) + '/../spec_ui_helper'

describe "Adding WineLibrary rss feed to LimeCast.com" do
  it 'should bring up sign up/sign in box' do
    browser.go("")
    browser.go("/add")
    browser.text_field(:name, "feed[url]").set("#{browser.url}/test_data/wine-library-tv.rss")
    browser.button(:value, "Add").click

    html.should have_tag("div.status_message", /Getting RSS/)

    try_for(60.seconds) do
      html.should have_tag("div.status_message", /Yum/)
    end

    browser.text_field(:id, "quicksignin_login").set("JustinCamerer")
    browser.text_field(:id, "quicksignin_password").set("supersecret")
    browser.execute("$.quickSignIn.showSignUp()")
    browser.text_field(:id, "quicksignin_email").set("jcamerer@limewire.com")
    browser.button(:id, "signup").click

    notify("Navigating to the WineLibraryTV page", "should allow you to download the episode")
    sleep(4)

    browser.go("/popular")
    sleep(1)

    browser.link(:text, "Wine Library TV").click
    sleep(1)

    # Watch Podcast for 5 seconds
    browser.link(:text, "Download").click
    sleep(5)

    notify("Commenting on the WineLibraryTV page", "should be allowed")
    sleep(4)

    ## Go back
    browser.execute("history.go(-1)")
    sleep(1)

    # Writes a review
    browser.text_field(:id, "review_title_new").set("Very Informative")
    browser.text_area(:id, "review_body_new").set("I can dig it.")
    browser.button(:value, "Save").click
    sleep(3)

    notify("Going to the user profile page", "should allow log out")
    sleep(4)

    browser.link(:text, "JustinCamerer (2)").click
    sleep(1)

    browser.link(:text, "Signout").click

    # New user shows up to the site
    notify("New user on site", "should be able to rate a comment")
    sleep(8)

    browser.go("/popular")
    browser.link(:text, "Wine Library TV").click
    sleep(2)

    # Someone else comes to the site and thinks Justin's comment is insightful
    browser.execute("$('.insightful:first').click()")
    browser.text_field(:id, "quicksignin_login").set("JustinsMom")
    browser.text_field(:id, "quicksignin_password").set("supersecret")
    browser.execute("$.quickSignIn.showSignUp()")
    browser.text_field(:id, "quicksignin_email").set("mommacamerer@limewire.com")
    browser.button(:id, "signup").click

    sleep(1)

    browser.go("/Wine-Library-TV")

    notify("Logged in user", "should be able to favorite a podcast")
    sleep(4)

    # Marks this podcast as her favorite
    browser.execute("$('.favorite_link:first').click()")
    sleep(1)
    browser.refresh

    notify("The End", "")
    sleep(5)
  end
end
