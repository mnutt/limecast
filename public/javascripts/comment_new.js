jQuery(document).ready(function(){
  jQuery('form#new_comment').submit(function(){
    var new_comment_form = $(this);
    jQuery.ajax({
      type:    'post',
      url:     jQuery(this).attr('action'),
      data:    jQuery(this).serialize(),
      success: function(resp){
        jQuery('#comments_list').append(resp);
        jQuery('a.delete').show(); // Show all delete links.
        new_comment_form.hide();
      }
    });


    return false;
  });
});

