attachPodcastEditEvents = function(){
  // for the podcast edit form
  $('#edit_actions').map(function(){
    var show_div  = $(this);
    var edit_form = $(this).find('#edit_form');

    edit_form.find('input.cancel').click(function(){
      show_div.show(); edit_form.hide();
      return false;
    });
  });

  // this is on user#show
  $('a.favorite_toggle_link').click(function(link){
    favorite_link = $(this);
    favorite_url = favorite_link.attr('href');

    $.post(favorite_url, function() {
      if(favorite_link.attr('title')=='This is a favorite.') {
        favorite_link.attr('title', 'Favorite this!').html('<img src="/images/icons/favorite.png" class="inline_icon" alt="" />Unfavorite');
      } else {
        favorite_link.attr('title', 'This is a favorite.').html('<img src="/images/icons/not_favorite.png" class="inline_icon" alt="" />Favorite');
      }
    });
    return false;

  });

  $('a.favorite_link').mustBeLoggedInBeforeSubmit({
    quick_signin: '.quick_signin.after_favoriting',
    success: function(resp) {
      $('a.favorite_link').replaceWith('<span><img src="/images/icons/favorite.png" class="inline_icon" />My Favorite</span>');
    }
  });

  $('.quick_signin.inline').quickSignIn({
    success: function(){ window.location.reload(); }
  });

  $('a.make_primary').click(function(link){
    $.ajax({
       type: 'post',
       url:  $('form.edit').attr('action'),
       data: "podcast_attr[primary_feed_id]="+$(this).attr('rel')+"&authenticity_token="+$('form.edit input[name=authenticity_token]').attr('value'),
       success: function(resp) {
         $('#edit_form').replaceWith(resp);
         attachPodcastEditEvents();
         $('#edit_form').show();
       }
     });
    // alert($(this).attr('rel'));
  });
}

$(document).ready(function(){
  attachPodcastEditEvents();
});

