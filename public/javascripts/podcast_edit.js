attachPodcastEditEvents = function(){
  // This is the favorite_link on Podcast#show pages
  $('a.favorite_link').click(function() {
    favorite_link = $(this);
    favorite_url = favorite_link.attr('href');
 
    $.post(favorite_url, {}, function(resp) {
      if(resp.logged_in) {
        favorite_link.replaceWith('<span><img src="/images/icons/favorite.png" class="inline_icon" alt="" />My Favorite</span>');
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

