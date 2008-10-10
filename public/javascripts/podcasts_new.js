jQuery(document).ready(function(){
  jQuery('form#new_podcast').submit(function(){

    var poll_for_status = function(response) {
      var feed_url = jQuery('#feed_url').attr('value');
      var form_clone = jQuery('#added_podcast').clone();
      form_clone.attr('id', null);
      form_clone.find('.text').attr('value', feed_url);
      form_clone.show();

      jQuery('#feed_url').val("");
      jQuery('#added_podcast_list').append(form_clone);


      if(jQuery('#inline_signin'))
        jQuery('#inline_signin').show();

      jQuery.periodic(function(controller){
        var callback = function(response) {
          form_clone.find('.status').html(response);
          if(/finished/g.test(response))
            controller.stop();
        };

        jQuery.ajax({
          url:      '/status',
          type:     'post',
          data:     {feed: feed_url},
          dataType: 'html',
          success:  callback,
          error:    callback
        });

        return true;
      }, {frequency: 1});
    };

    jQuery.ajax({
      data:     jQuery(this).serialize(),
      dataType: 'script',
      type:     'post',
      url:      '/podcasts',
      success:  poll_for_status
    });
    // Keep form from submitting
    return false;
  });
});

