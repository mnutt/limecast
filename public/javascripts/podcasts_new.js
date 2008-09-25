$(document).ready(function(){
  $('form#new_podcast').submit(function(){
    $.ajax({
      data:     $(this).serialize(),
      dataType: 'script',
      type:     'post',
      url:      '/podcasts'
    });

    var feed_url = $(this).find('#podcast_feed_url').attr('value');
    var form_clone = $('#added_podcast').clone();
    form_clone.find('.text').attr('value', feed_url);
    form_clone.show();

    $('#added_podcast_list').append(form_clone);

    if($('#inline_login'))
      $('#inline_login').show();

    $.periodic(function(controller){
      var callback = function(response) {
        $('#status').html(response);

        if(/loading/g.test(response))
          controller.stop();
      };
    
      $.ajax({
        url:     '/status/' + encodeURIComponent(feed_url).replace(/%2F/g, '/'),
        success: callback,
        error:   callback
      });

      return true;
    }, {frequency: 1});

    // Keep form from submitting
    return false;
  });
});

