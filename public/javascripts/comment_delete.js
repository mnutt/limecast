jQuery(document).ready(function(){
  jQuery('li.review').map(function(){
    var review_li   = jQuery(this);
    var delete_link = jQuery(this).find('a.delete');

    // Reveal delete link if they have javascript enabled.
    delete_link.show();

    delete_link.click(function(){
      // Remove the review from the db.
      jQuery.ajax({
        type: 'post',
        url:  jQuery(this).attr('href'),
        data: '_method=delete&authenticity_token=' + AUTH_TOKEN
      });

      // Remove the review from the UI.
      review_li.replaceWith('');

      return false;
    });
  });
});

