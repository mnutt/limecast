$(document).ready(function(){
  $('#new_podcast').submit(function(){
    var podcast_url = $('#podcast_url').attr('value');

    // clone the disabled form and append it
    var form_clone = $('#added_podcast').clone().attr('id', '');
    form_clone.attr('id', null);
    form_clone.find('button[type=submit]').attr('disabled', 'disabled').unbind('click').css('color', '#999');
    form_clone.find('input[type=text]').attr('value', podcast_url);
    form_clone.show();
    $('#added_podcast_list').append(form_clone.wrap('li'));

    // reset the form
    $('#podcast').hide();
    $('#podcast_url').unbind().val("").blur(); // unbind the jquery.default-text.js stuff, set val to empty, and blur it so focus works

    // FIX
    // if($('#inline_signin'))
    //   $('#inline_signin').show();
    
    var poll = function(wait) {
      setTimeout(function(){
        $.ajax({
          url:      '/status',
          type:     'post',
          data:     {podcast: podcast_url},
          dataType: 'html',
          success:  function(resp) { 
            form_clone.find('.status').html(resp);
            if(/finished/g.test(resp)) {
              $('#new_podcast').show().find('#podcast_url').focus();
            } else {
              poll(wait * 2); // decay
            }
          }
        });
      }, wait * 1000);
    };
    poll(0.1);
    return false;
  });
});

