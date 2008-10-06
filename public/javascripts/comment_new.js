jQuery(document).ready(function(){
  jQuery('.quick_signin.inline').quickSignIn({
    ajax: false
  });

  jQuery('form#new_comment').submit(function(){
    var new_comment_form = $(this);
    jQuery.ajax({
      type:    'post',
      url:     jQuery(this).attr('action'),
      data:    jQuery(this).serialize(),
      dataType: "json",
      success: function(resp){
        if(resp.logged_in) {
          jQuery('#comments_list').append(resp.html);
          jQuery('a.delete').show(); // Show all delete links.
        } else {
          jQuery('.quick_signin.inline').show();
        }

        new_comment_form.hide();
      }
    });

    return false;
  });
});

