$.ajaxSetup({
  'beforeSend': function(xhr) { xhr.setRequestHeader("Accept", "text/javascript")}
})

// Method hooks up all of the input text boxes that should have default labels
function defaultText() {
  $("#podcast_url, #accounts_forgot_password #email, #search_podcast_q, " + 
    "#q, #user_tagging_tag_string").inputDefaultText();
}

// Handles truncated "more" and "less" links
function truncatedText() {
  $("a.truncated").click(function(){
    var text = $(this).text();
    var oppositeText = text == "less" ? "more" : "less";

    $(this).text(oppositeText);
    $(this).parent().find(".truncated." + oppositeText).hide();
    $(this).parent().find(".truncated." + text).show();

    return false;
  }); 
}

function favoriteLink() {
  $('a.favorite_link, a.unfavorite_link').click(function() {
    var favorite_link = $(this);
    var favorite_url = favorite_link.attr('href');

    $.post(favorite_url, {}, function(resp) { if(resp.logged_in) window.location.reload(); }, 'json');
    return false;
  });
}

function setupCluetips() {
  var default_options = { local: true, arrows: true, width: 350, showTitle: false };
  $('a.tips').cluetip(default_options);
  
  if(!LOGGED_IN) {
    // $.extend(default_options, {activation: 'click', sticky: true, onShow: function(){$.quickSignIn.setup()}});

    $.extend(default_options, {positionBy: 'auto', leftOffset: -10});
    $('#podcast_tag_form_cluetip_link').cluetip(default_options);
    
    $.extend(default_options, {positionBy: 'bottomTop', topOffset: 25});
    $('a.login').cluetip(default_options); 
    $('a.favorite_link').cluetip(default_options); 
    $('a.unfavorite_link').cluetip(default_options); 

    $.extend(default_options, {positionBy: 'bottomTop'});
    $('a.cluetip_add_link').cluetip(default_options);

    $.extend(default_options, {height: 350, onShow: function(){$.quickSignIn.showSignUp(); $.quickSignIn.setup();}});
    $('a.signup').cluetip(default_options);
  }
}

function setupAuth() {
  $("#auth form").authSetup();
  $("#auth_link").authLink();
  $("#sign_out_link").signoutSetup();
}

function setupTabs() {
  $('.tabify').tabs({ navClass: 'tabs', containerClass: 'tabs-cont' });
}

$(function() {
  defaultText();
  truncatedText();
  favoriteLink();
  setupAuth();
//  setupCluetips();
//  setupTabs();
});
