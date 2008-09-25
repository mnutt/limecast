

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

// 
//   $.ajax(
//     {
//       data:     $.param($(this).serializeArray()) + '&amp;authenticity_token=' + encodeURIComponent('1c4f6c74d275107710bba4b5ca41a0ae28f7d272'),
//       dataType: 'script',
//       error:    function(request){new Lime.Widgets.Add.Podcast()},
//       success:  function(request){new Lime.Widgets.Add.Podcast()},
//       type:     'post',
//       url:      '/podcasts'
//     }
//   );
// 
// 
// 
// 
// 
// 
// Lime.Widgets.Add = Class.create();
// Lime.Widgets.Add.Podcast = Class.create();
// Object.extend(Lime.Widgets.Add.Podcast, {
//   list: Array
// });
// Object.extend(Lime.Widgets.Add.Podcast.prototype, {
//   initialize: function() {
//     feed_url = $('podcast_feed_url').value;
//     $('new_podcast').reset();
//     form_html = $('form_clone').innerHTML.replace(/CHANGE/, feed_url);
// 
//     status = Builder.node('div', { className: "status" });
//     form = Builder.node('div', { className: "form" });
//     form.innerHTML = form_html;
//     podcast = Builder.node('div', { className: "added_podcast" }, [ form, status ]);
//     $('added_podcast_list').appendChild(podcast);
//     this._updater = new Ajax.PeriodicalUpdater(status,
//                                                '/status/' + encodeURIComponent(feed_url).replace(/%2F/g, '/'),
//                                                {method: 'get', frequency: 1, decay: 2, stopOnText: "status_message"});
// 
// 
//     if($('inline_login')) { $('inline_login').show(); }
//   }
// });
