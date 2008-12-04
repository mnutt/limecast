attachPodcastEditEvents = function(){
  $('a.favorite_link').click(function() {
    favorite_link = $(this);
    favorite_url = favorite_link.attr('href');
 
    $.post(favorite_url, {}, function(resp) {
      if(resp.logged_in) {
        if(favorite_link.attr('title')=='This is a favorite.') {
          favorite_link.attr('title', 'Favorite this!').html('<img src="/images/icons/favorite.png" class="inline_icon" alt="" />Unfavorite');
        } else {
          favorite_link.attr('title', 'This is a favorite.').html('<img src="/images/icons/not_favorite.png" class="inline_icon" alt="" />Favorite');
        }
      } else {
        return $.quickSignIn.attach($('.quick_signin_container.after_favoriting'), 
          {message:'Sign up or sign in to save your favorite.'});
      }
    }, 'json');
    
    return false;
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

