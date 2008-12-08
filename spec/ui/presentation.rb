require File.dirname(__FILE__) + '/../spec_ui_helper'

describe "Adding podcast while logged out" do
  it 'should eventually show success' do
    browser.go("")
    browser.go("/add")
    browser.text_field(:name, "feed[url]").set("#{browser.url}/test_data/wine-library-tv.rss")
    browser.button(:value, "Add").click

    html.should have_tag("div.status_message", /Getting RSS/)

    try_for(10.seconds) do
      html.should have_tag("div.status_message", /Yum/)
    end

    browser.text_field(:id, "quicksignin_login").set("JustinCamerer")
    browser.text_field(:id, "quicksignin_password").set("supersecret")
    browser.execute("$.quickSignIn.showSignUp()")
    browser.text_field(:id, "quicksignin_email").set("jcamerer@limewire.com")
    browser.button(:id, "signup").click

    browser.go("/all")

    browser.link(:text, "Wine Library TV").click

    # Watch Podcast for 5 seconds
    browser.link(:text, "Download").click
    sleep(5)

    ## Go back
    browser.execute("history.go(-1)")
    sleep(1)

    # Writes a review
    browser.text_field(:id, "review_title_new").set("Very Informative")
    browser.text_area(:id, "review_body_new").set("I can dig it.")
    browser.button(:value, "Save").click
    sleep(2)

    # Logs out
    #browser.go("/logout")

    browser.link(:text, "JustinCamerer (2)").click

    sleep(1)

    browser.link(:text, "Signout").click

    # New user shows up to the site
    sleep(5)

    browser.go("/all")
    browser.link(:text, "Wine Library TV").click

    # Someone else comes to the site and thinks Justin's comment is insightful
    browser.execute("$('.insightful:first').click()")
    browser.text_field(:id, "quicksignin_login").set("JustinsMom")
    browser.text_field(:id, "quicksignin_password").set("supersecret")
    browser.execute("$.quickSignIn.showSignUp()")
    browser.text_field(:id, "quicksignin_email").set("mommacamerer@limewire.com")
    browser.button(:id, "signup").click
    #browser.execute("$('#signup').click()")

    sleep(2)

    browser.execute("window.location.reload()")

    sleep(2)

    # Marks this podcast as her favorite
    browser.execute("$('.favorite_link:first').click()")
    browser.refresh

    sleep(120)
  end
end
