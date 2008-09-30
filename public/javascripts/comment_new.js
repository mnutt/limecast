jQuery(document).ready(function(){
  jQuery('form#new_comment').submit(function(){
    jQuery.ajax({
      type:    'post',
      url:     jQuery(this).attr('action'),
      data:    jQuery(this).serialize(),
      success: function(resp){
        jQuery('#comments_list').append
      }
    });

    return false;
  });
});

