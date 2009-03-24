$.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

// Method hooks up all of the input text boxes that should have default labels
function defaultText() {
  $("#feed_url, #accounts_forgot_password #email, #search_podcast_q, " + 
    ".limecast_form .new_podcast_feed_url, #q, #user_tagging_tag_string").inputDefaultText();
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
  $('a.favorite_link').click(function() {
    if(LOGGED_IN) {
      var favorite_link = $(this);
      var favorite_url = favorite_link.attr('href');
  
      $.post(favorite_url, {}, function(resp) { window.location.reload(); }, 'json');
    }
    return false;
  });
}

function setupCluetips() {
  var default_options = { local: true, arrows: true, width: 350, showTitle: false };
  $('a.tips').cluetip(default_options);
  
  if(!LOGGED_IN) {
    default_options = $.extend({activation: 'click', sticky: true, onShow: function(){$.quickSignIn.setup()}}, default_options);

    var options = $.extend({positionBy: 'auto', leftOffset: -50}, default_options);
    $('#podcast_tag_form .submit').cluetip(options);
    
    default_options = $.extend({positionBy: 'bottomTop', topOffset: 25}, default_options);
    $('a.login').cluetip(default_options); 

    default_options = $.extend({positionBy: 'bottomTop'}, default_options);
    $('a.cluetip_add_link').cluetip(default_options);

    default_options = $.extend({onShow: function(){ $.quickSignIn.showSignUp(); $.quickSignIn.setup(); }}, default_options);
    $('a.signup').cluetip(default_options);
  }
}

function setupTabs() {
  $('.tabify').tabs({ navClass: 'tabs', containerClass: 'tabs-cont' });
}

$(function() {
  defaultText();
  truncatedText();
  favoriteLink();
  setupCluetips();
  setupTabs();
});
