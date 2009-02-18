attachPodcastEditEvents = function(){
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

