$(document).ready(function(){
  $('form#new_podcast').submit(function(){

    var poll_for_status = function(response) {
      var feed_url = $('#feed_url').attr('value');
      var form_clone = $('#added_podcast').clone();
      form_clone.attr('id', null);
      form_clone.find('.text').attr('value', feed_url);
      form_clone.show();

      $('#feed_url').val("");
      $('#added_podcast_list').append(form_clone);
      $("#new_podcast").find('label.default').text(''); // only first input should have the example url


      // FIX
      // if($('#inline_signin'))
      //   $('#inline_signin').show();

      $.periodic(function(controller){
        var callback = function(response) {
          form_clone.find('.status').html(response);
          if(/finished/g.test(response))
            controller.stop();
        };

        $.ajax({
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

    $.ajax({
      data:     $(this).serialize(),
      dataType: 'script',
      type:     'post',
      url:      '/podcasts',
      success:  poll_for_status
    });
    // Keep form from submitting
    return false;
  });
});

