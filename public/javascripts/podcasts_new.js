jQuery(document).ready(function(){
  jQuery('form#new_podcast').submit(function(){
    jQuery.ajax({
      data:     jQuery(this).serialize(),
      dataType: 'script',
      type:     'post',
      url:      '/podcasts'
    });

    var feed_url = jQuery(this).find('#podcast_feed_url').attr('value');
    var form_clone = jQuery('#added_podcast').clone();
    form_clone.find('.text').attr('value', feed_url);
    form_clone.show();

    jQuery('#added_podcast_list').append(form_clone);
    jQuery('#podcast_feed_url').val("");


    if(jQuery('#inline_login'))
      jQuery('#inline_login').show();

    jQuery.periodic(function(controller){
      var callback = function(response) {
        jQuery('#status').html(response);

        if(/loading/g.test(response))
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

    // Keep form from submitting
    return false;
  });
});

